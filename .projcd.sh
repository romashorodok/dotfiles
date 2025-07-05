#!/usr/bin/env bash

tmux_sessionizer() {
  local selected selected_name tmux_running

  if [[ $# -eq 1 ]]; then
    selected=$1
  else
    read -r selected
  fi

  if [[ -z $selected ]]; then
    return 0
  fi

  selected_name=$(basename "$selected" | tr . _)
  tmux_running=$(pgrep tmux)

  if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    return 0
  fi

  if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux select-window -t "$selected_name:1"
  fi

  tmux switch-client -t "$selected_name"
}

projcd() {
  base="$HOME/proj"
  query=""
  i=1
  key=""
  start_idx=1
  max_lines=15

  if ! pushd "$base" > /dev/null 2>&1; then
    echo "Failed to access $base" >&2
    return 1
  fi

  full_dirs=$(ls -d -- */ 2>/dev/null | sed 's:/$::')
  if [ -z "$full_dirs" ]; then
    echo "No directories found in $base" >&2
    popd > /dev/null
    return 1
  fi

  if command -v rg >/dev/null 2>&1; then
    search_cmd="rg"
    search_msg="Using ripgrep (rg) for filtering"
  else
    search_cmd="grep"
    search_msg="Using grep for filtering"
  fi

  while :; do
    if [ -z "$query" ]; then
      filtered_dirs="$full_dirs"
    else
      fuzzy_regex=$(printf '%s' "$query" | sed 's/./&.*?/g' | sed 's/\.\*\?*$//')
      if [ "$search_cmd" = "rg" ]; then
        filtered_dirs=$(printf '%s\n' "$full_dirs" | rg -i -e "$fuzzy_regex" || true)
      else
        filtered_dirs=$(echo "$full_dirs" | grep -i -E "$fuzzy_regex" || true)
      fi
    fi

    count=$(echo "$filtered_dirs" | wc -l)
    [ "$count" -eq 0 ] && i=0 start_idx=1

    [ "$i" -gt "$count" ] && i=$count
    [ "$i" -lt 1 ] && i=1

    if [ "$i" -lt "$start_idx" ]; then
      start_idx=$i
    elif [ "$i" -ge $((start_idx + max_lines)) ]; then
      start_idx=$((i - max_lines + 1))
    fi

    clear
    echo "$search_msg"
    echo "Search folders in $base (type to filter, Backspace to delete):"
    echo "Query: $query"
    echo "Navigate: j/k, Enter to cd, q to quit"
    echo

    [ "$start_idx" -gt 1 ] && echo "  ... (and above)"

    idx=$start_idx
    end_idx=$((start_idx + max_lines - 1))
    echo "$filtered_dirs" | sed -n "${start_idx},${end_idx}p" | while IFS= read -r d; do
      [ "$idx" -eq "$i" ] && echo "> $d" || echo "  $d"
      idx=$((idx + 1))
    done

    [ "$count" -gt "$end_idx" ] && echo "  ... (and more)"

    old_stty=$(stty -g)
    stty -icanon -echo min 1 time 0
    key=$(dd bs=1 count=1 2>/dev/null)
    stty "$old_stty"

    case "$key" in
      j) [ "$i" -lt "$count" ] && i=$((i + 1)) ;;
      k) [ "$i" -gt 1 ] && i=$((i - 1)) ;;
      "")  # Enter
        selected_dir=$(echo "$filtered_dirs" | sed -n "${i}p")
        popd > /dev/null
        tmux_sessionizer "$base/$selected_dir"
        return
        ;;
      q)
        echo "Aborted"
        popd > /dev/null
        break
        ;;
      $(printf '\x7f')|$(printf '\b'))  # Backspace
        query=$(printf '%s' "$query" | sed 's/.$//')
        i=1
        start_idx=1
        ;;
      *)
        if printf '%s' "$key" | LC_ALL=C grep -q '^[ -~]$'; then
          query="$query$key"
          i=1
          start_idx=1
        fi
        ;;
    esac
  done
}
