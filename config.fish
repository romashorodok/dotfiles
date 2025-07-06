function tmux_sessionizer
    set selected_name
    set selected
    set tmux_running

    if test (count $argv) -eq 1
        set selected $argv[1]
    else
        read -l selected
    end

    if test -z "$selected"
        return 0
    end

    set selected_name (basename $selected | tr . _)
    set tmux_running (pgrep tmux)

    if test -z "$TMUX" -a -z "$tmux_running"
        tmux new-session -s $selected_name -c $selected
        return 0
    end

    if not tmux has-session -t "$selected_name"
        tmux new-session -ds $selected_name -c $selected
        tmux select-window -t "$selected_name:1"
    end

    tmux switch-client -t $selected_name
end

function projcd
    set base "$HOME/proj"
    set query ""
    set i 1
    set key ""
    set start_idx 1
    set max_lines 15

    if not pushd $base >/dev/null ^/dev/null
        echo "Failed to access $base" >&2
        return 1
    end

    set full_dirs (ls -d */ 2>/dev/null | sed 's:/$::')
    if test -z "$full_dirs"
        echo "No directories found in $base" >&2
        popd >/dev/null
        return 1
    end

    if type -q rg
        set search_cmd "rg"
        set search_msg "Using ripgrep (rg) for filtering"
    else
        set search_cmd "grep"
        set search_msg "Using grep for filtering"
    end

    while true
        if test -z "$query"
            set filtered_dirs $full_dirs
        else
            set fuzzy_regex (string join "" (string split "" $query | sed 's/./&.*?/g' | sed 's/\.\*\?*$//'))
            if test "$search_cmd" = "rg"
                set filtered_dirs (printf '%s\n' $full_dirs | rg -i -e "$fuzzy_regex" || true)
            else
                set filtered_dirs (printf '%s\n' $full_dirs | grep -i -E "$fuzzy_regex" || true)
            end
        end

        set count (count $filtered_dirs)
        if test "$count" -eq 0
            set i 0
            set start_idx 1
        end

        if test "$i" -gt "$count"
            set i $count
        else if test "$i" -lt 1
            set i 1
        end

        if test "$i" -lt "$start_idx"
            set start_idx $i
        else if test "$i" -ge (math $start_idx + $max_lines)
            set start_idx (math $i - $max_lines + 1)
        end

        clear
        echo $search_msg
        echo "Search folders in $base (type to filter, Backspace to delete):"
        echo "Query: $query"
        echo "Navigate: j/k, Enter to cd, q to quit"
        echo ""

        if test "$start_idx" -gt 1
            echo "  ... (and above)"
        end

        set idx $start_idx
        set end_idx (math $start_idx + $max_lines - 1)

        set slice_range "$start_idx,$end_idx"
        for d in (string split \n (string join \n $filtered_dirs | sed -n "$slice_range"p))

            if test "$idx" -eq "$i"
                echo "> $d"
            else
                echo "  $d"
            end
            set idx (math $idx + 1)
        end


        if test "$count" -gt "$end_idx"
            echo "  ... (and more)"
        end

        stty -icanon -echo min 1 time 0
        set key (dd bs=1 count=1 2>/dev/null)
        stty sane

        switch $key
            case j
                if test "$i" -lt "$count"
                    set i (math $i + 1)
                end
            case k
                if test "$i" -gt 1
                    set i (math $i - 1)
                end
            case ''
                set line_num "$i"
                set selected_dir (string split \n $filtered_dirs | sed -n "$line_num"p)
                popd >/dev/null
                tmux_sessionizer "$base/$selected_dir"
                return
            case q
                echo "Aborted"
                popd >/dev/null
                break
            case (printf '\x7f') (printf '\b')
                set query (string sub -l (math (string length -- $query) - 1) -- $query)
                set i 1
                set start_idx 1
            case '*'
                if string match -rq '^[ -~]$' -- $key
                    set query "$query$key"
                    set i 1
                    set start_idx 1
                end
        end
    end
end


tmux set -ga terminal-overrides ",screen-256color*:Tc"
tmux set-option -g default-terminal screen-256color
tmux set -s escape-time 0
tmux set -g mouse on

tmux unbind C-b
tmux set-option -g prefix C-a
tmux bind-key C-a send-prefix
tmux set -g status-style 'bg=#333333 fg=#5eacd3'

tmux bind r source-file ~/.tmux.conf
tmux set -g base-index 1

tmux set-window-option -g mode-keys vi
tmux bind -T copy-mode-vi v send-keys -X begin-selection

tmux bind -r ^ last-window
tmux bind -r k select-pane -U
tmux bind -r j select-pane -D
tmux bind -r h select-pane -L
tmux bind -r l select-pane -R

# tmux bind-key -r f run-shell "tmux neww ~/.projcd.sh"
tmux bind-key -r f run-shell "tmux neww fish -c 'source ~/.config/fish/config.fish; projcd; exec fish'"


if status is-interactive
    set selected (basename (pwd))

    if not tmux has-session -t=$selected 2>/dev/null
        tmux new-session -ds $selected -c $selected
    end

    tmux attach-session -t $selected
end

set -gx EDITOR hx

# set -gx PATH $PATH $HOME/proj/depot_tools
# set -gx PATH $PATH $HOME/proj/proj/gn/out/gn
# set -gx PATH $PATH $HOME/proj/zig/build/stage3/bin
# set -gx PATH $PATH $HOME/proj/zls/zig-out/bin
set -gx PATH $PATH $HOME/.local/bin
set -gx PATH $PATH $HOME/local/nvim/bin
set -gx PATH $PATH $HOME/go/bin
set -gx PATH $PATH $HOME/.cargo/bin
set -gx PATH $PATH $HOME/proj/yazi/target/release

# set -gx PATH $PATH $HOME/proj/binaryen/bin
# set -gx PATH $PATH $HOME/proj/binaryen/lib
# set -gx PATH $PATH $HOME/proj/llvm-project/build/bin
# set -gx PATH $PATH $HOME/proj/llvm-project/build/lib
# set -gx PATH $PATH $HOME/proj/emscripten
# set -gx PATH $PATH $HOME/proj/emsdk
# set -gx PATH $PATH $HOME/proj/emsdk/upstream/emscripten

# set -Ua fish_user_paths "$HOME/.rye/shims"

function __auto_source_venv --on-variable PWD --description "Activate/Deactivate virtualenv on directory change"
    status --is-command-substitution; and return

    # Check if we are inside a git directory
    if git rev-parse --show-toplevel &>/dev/null
        set gitdir (realpath (git rev-parse --show-toplevel))
        set cwd (pwd -P)
        # While we are still inside the git directory, find the closest
        # virtualenv starting from the current directory.
        while string match "$gitdir*" "$cwd" &>/dev/null
            if test -e "$cwd/.venv/bin/activate.fish"
                source "$cwd/.venv/bin/activate.fish" &>/dev/null
                return
            else
                set cwd (path dirname "$cwd")
            end
        end
    end
    # If virtualenv activated but we are not in a git directory, deactivate.
    if test -n "$VIRTUAL_ENV"
        deactivate
    end
end

__auto_source_venv
