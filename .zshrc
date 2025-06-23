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

. "$HOME/.cargo/env"

selected="$HOME"
selected_name=$(basename "$selected" | tr . _)

# If already inside tmux, do nothing
if [[ -n $TMUX ]]; then
  return
fi

# Check if tmux server is running
if ! tmux ls &> /dev/null; then
  # No server, start a new session (this creates the server too)
  exec tmux new-session -s "$selected_name" -c "$selected"
else
  # Server running, check if session exists
  if ! tmux has-session -t "$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
  fi
  # Attach to the session
  exec tmux attach-session -t "$selected_name"
fi

