autoload -U add-zsh-hook

function __auto_source_venv() {
  # Prevent running during command substitution
  [[ -o interactive ]] || return

  # Check if we're inside a Git repository
  if git_root=$(git rev-parse --show-toplevel 2>/dev/null); then
    cwd=$(pwd -P)

    while [[ "$cwd" == "$git_root"* ]]; do
      if [[ -f "$cwd/.venv/bin/activate" ]]; then
        # Only activate if not already activated
        if [[ "$VIRTUAL_ENV" != "$cwd/.venv" ]]; then
          source "$cwd/.venv/bin/activate" &>/dev/null
        fi
        return
      else
        cwd=$(dirname "$cwd")
      fi
    done
  fi

  # If we're no longer in a Git repo but a venv is active, deactivate
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate 2>/dev/null
  fi
}

add-zsh-hook chpwd __auto_source_venv

. "$HOME/.projcd.sh"

autoload -U colors && colors
bindkey -e
PS1='%F{#5eacd3}%n@%m:%~%f %# '
export COLORTERM=truecolor

HISTSIZE=10000
SAVEHIST=10000

autoload -U compinit && compinit
autoload -U colors && colors
zmodload zsh/complist

_comp_options+=(globdots)

alias vim="nvim"
alias vi="nvim"

export EDITOR="nvim"
export MANPAGER="nvim +Man!"

mkdir -p "$HOME/.cargo/env" >/dev/null 2>&1 && . "$HOME/.cargo/env" >/dev/null 2>&1

selected="$HOME"
selected_name=$(basename "$selected" | tr . _)

# If already inside tmux, do nothing
if [[ -n $TMUX ]]; then
  return
fi

# Check if tmux server is running
if ! tmux ls &> /dev/null; then
  # No server, start a new session (this creates the server too)
  exec tmux new-session -ds "$selected_name"
else
  # Server running, check if session exists
  if ! tmux has-session -t "$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name"
  fi

  # Attach to the session
  exec tmux attach-session -t "$selected_name"
fi

