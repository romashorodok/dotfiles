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

tmux bind-key -r f run-shell "tmux neww ~/.projcd.sh"

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
