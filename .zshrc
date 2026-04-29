#!/bin/zsh

# .zshrc
# Converted from .bashrc

#######################################################################
# Set up environment and PATH
#######################################################################

# Startup

echo "Hello, Anat"

# Functions --- {{{

path_ladd() {
  # Takes 1 argument and adds it to the beginning of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1${PATH:+":$PATH"}"
  fi
}

path_radd() {
  # Takes 1 argument and adds it to the end of the PATH
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="${PATH:+"$PATH:"}$1"
  fi
}

# }}}
# Exported variables --- {{{

# Configure less (de-initialization clears the screen)
# Gives nicely-colored man pages
export PAGER=less
export LESS='--ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --clear-screen'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Editor
export EDITOR=vim
export SHELL=zsh

# environment variable controlling difference between HI-DPI / Non HI_DPI
export GDK_SCALE=0

# }}}
# History settings --- {{{

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

setopt HIST_IGNORE_DUPS       # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicate when new one is added
setopt HIST_IGNORE_SPACE      # Don't record entries starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to history file
setopt SHARE_HISTORY          # Share history between sessions
setopt APPEND_HISTORY         # Append to history file

# }}}
# Path additions --- {{{

HOME_BIN="$HOME/bin"
if [ -d "$HOME_BIN" ]; then
  path_ladd "$HOME_BIN"
fi

HOME_LOCAL_BIN="$HOME/.local/bin"
if [ ! -d "$HOME_LOCAL_BIN" ]; then
  mkdir -p "$HOME_LOCAL_BIN"
fi
path_ladd "$HOME_LOCAL_BIN"

export PATH

# }}}

#######################################################################
# Interactive Zsh session settings
#######################################################################

# Source sensitive file --- {{{

[[ -f ~/.zsh/sensitive ]] && source ~/.zsh/sensitive

# }}}
# Aliases --- {{{

# enable color support of ls and also add handy aliases
# if [ -x /usr/bin/dircolors ]; then
#   test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
#   alias ls='ls --color=auto'
#   alias dir='dir --color=auto'
#   alias vdir='vdir --color=auto'

#   alias grep='grep --color=auto'
#   alias fgrep='fgrep --color=auto'
#   alias egrep='egrep --color=auto'
# fi


# Enable colors for ls
export CLICOLOR=1

# Define the colors (Directory, Symlink, Socket, Pipe, Exec, etc.)
# This example sets Directories to Bold Blue and Executables to Red
export LSCOLORS="Gxfxcxdxbxegedabagacad"

alias ls='ls -G'``

# Make "vim" direct to nvim
alias vim=nvim

# ls aliases
alias ll='ls -alF'
alias l='ls -CF'

# Set copy/paste helper functions
alias pbcopy="perl -pe 'chomp if eof' | xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"

# alias for VPN
alias nmc="nmcli c up aws"

# alias for KIP-Rocket
alias rocket="cd ~/keplergrp/KIP-Rocket/ && tmux"
alias kplr="cd ~/keplergrp/ && tmux"

# alias for developer journal
alias journal="vim ~/playground/developer-journal.md"

# }}}
# Functions --- {{{

# activate virtual environment from any directory from current and up
VIRTUAL_ENV_DEFAULT=.venv

va() {
  local venv_name="$VIRTUAL_ENV_DEFAULT"
  local old_venv=$VIRTUAL_ENV
  local slashes=${PWD//[^\/]/}
  local current_directory="$PWD"
  for (( n=${#slashes}; n>0; --n )); do
    if [ -d "$current_directory/$venv_name" ]; then
      source "$current_directory/$venv_name/bin/activate"
      if [[ "$old_venv" != "$VIRTUAL_ENV" ]]; then
        echo "Activated $(python --version) virtualenv in $VIRTUAL_ENV"
      fi
      return
    fi
    current_directory="$current_directory/.."
  done
}

# Create and activate a virtual environment with all Python dependencies
ve() {
  local venv_name="$VIRTUAL_ENV_DEFAULT"
  local python_name="${1:-python}"
  if [ ! -d "$venv_name" ]; then
    $python_name -m venv "$venv_name"
    if [ $? -ne 0 ]; then
      echo "Virtualenv creation failed, aborting"
      return 1
    fi
    source "$venv_name/bin/activate"
    pip install -U pip
    deactivate
  else
    echo "$venv_name already exists, activating"
  fi
  source "$venv_name/bin/activate"
}

upgrade() {
  sudo -v
  sudo apt update
  sudo apt upgrade -y
  sudo apt autoremove -y
  sudo snap refresh
  mise self-update -y
  mise upgrade -y
  mise install -y
}

kip3() {
  local servicename
  servicename=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]')
  if docker compose ps "$servicename" &>/dev/null; then
    USERID=$(id -u) docker compose exec "$servicename" "$@"
  else
    echo "'$servicename' not found in compose.yml config"
    return 1
  fi
}

# }}}
# Prompt --- {{{

autoload -Uz vcs_info
precmd() { vcs_info }

zstyle ':vcs_info:git:*' formats '%b'

setopt PROMPT_SUBST

PROMPT='%B%F{115}%~ %f%b[${vcs_info_msg_0_}]
%B%F{magenta}%n@%m %F{248}$ %f%b'

# }}}
# Mise --- {{{

eval "$(mise activate zsh)"

# }}}
# AWS --- {{{

export AWS_PROFILE=default
export AWS_REGION=us-east-1
export CLAUDE_CODE_USE_BEDROCK=1

# }}}



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -Uz compinit && compinit
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
