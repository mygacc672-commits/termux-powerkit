#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#  termux-powerkit — Enhanced .bashrc
#  Source this from your ~/.bashrc:
#    source ~/.termux-powerkit/config/bashrc_extras.sh
# ============================================================

# ── Visual prompt ────────────────────────────────────────────
parse_git_branch() {
  git branch 2>/dev/null | grep '^*' | sed 's/* //'
}

# Colorful prompt: [user@host dir (branch)]$
export PS1='\[\033[0;36m\]┌─[\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;33m\]\h\[\033[0;36m\]]\[\033[0;37m\] \[\033[1;34m\]\w\[\033[0;35m\]$(git branch 2>/dev/null | grep "^*" | colrm 1 2 | xargs -I{} echo " ({})")\[\033[0m\]\n\[\033[0;36m\]└─\[\033[1;37m\]\$\[\033[0m\] '

# ── Quality of life ──────────────────────────────────────────
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend 2>/dev/null

# Auto-cd
shopt -s autocd 2>/dev/null

# ── Navigation aliases ───────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd $HOME'
alias dl='cd $HOME/downloads && ls'
alias docs='cd $HOME/storage/documents && ls'

# ── ls aliases ───────────────────────────────────────────────
alias ls='ls --color=auto'
alias ll='ls -lAh --color=auto'
alias la='ls -A --color=auto'
alias lt='ls -lAht --color=auto'         # sort by time
alias lz='ls -lAhS --color=auto'         # sort by size
alias tree='tree -C'

# ── Safety nets ──────────────────────────────────────────────
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'

# ── Network ──────────────────────────────────────────────────
alias myip='curl -s https://api.ipify.org && echo'
alias localip='ip addr | grep "inet " | awk "{print \$2}"'
alias ping='ping -c 5'
alias ports='ss -tulpn'
alias wget='wget -c'                      # resume by default

# ── System ───────────────────────────────────────────────────
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias top='htop 2>/dev/null || top'
alias bat='cat'                           # override if batcat available
command -v batcat &>/dev/null && alias bat='batcat'
command -v bat    &>/dev/null && alias cat='bat --paging=never'

# ── Git shortcuts ────────────────────────────────────────────
alias g='git'
alias gs='git status'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpl='git pull'
alias gcl='git clone'

# ── Python ───────────────────────────────────────────────────
alias py='python3'
alias py2='python2'
alias pip='pip3'
alias venv='python3 -m venv'
alias activate='source ./venv/bin/activate'
alias serve='python3 -m http.server'

# ── Development ──────────────────────────────────────────────
alias c='clear'
alias h='history'
alias hg='history | grep'
alias e='nano'
alias vi='vim'
alias reload='source ~/.bashrc'

# ── Termux specific ──────────────────────────────────────────
alias storage='termux-setup-storage'
alias clipboard='termux-clipboard-get'
alias clip='termux-clipboard-set'
alias vibrate='termux-vibrate'
alias notify='termux-notification'
alias battery='termux-battery-status'
alias bright='termux-brightness'

# ── Search & find ────────────────────────────────────────────
alias ff='find . -type f -name'           # ff "*.py"
alias fd='find . -type d -name'           # fd "node_modules"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias rgr='grep -r --color=auto'

# ── Archive shortcuts ────────────────────────────────────────
alias mktar='tar czf'                     # mktar archive.tar.gz files
alias untar='tar xzf'                     # untar archive.tar.gz
alias mkzip='zip -r'                      # mkzip archive.zip files

# ── Quick functions ──────────────────────────────────────────

# Extract any archive
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     unrar x "$1" ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.7z)      7z x "$1" ;;
      *)         echo "Unknown archive: $1" ;;
    esac
  else
    echo "File '$1' not found"
  fi
}

# mkcd: create dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# backup: copy file with .bak extension
backup() { cp "$1" "$1.bak.$(date +%Y%m%d_%H%M%S)"; }

# search running process
psg() { ps aux | grep -i "$1" | grep -v grep; }

# quick IP lookup
ipinfo() { curl -s "https://ipapi.co/${1:-}/json/" | python3 -m json.tool; }

# weather
weather() { curl -s "wttr.in/${1:-}?format=v2"; }

# cheat.sh
cheat() { curl -s "cheat.sh/$1" | head -50; }

# qr code from text
qr() { curl -s "qrenco.de/$1"; }

# Colorized man pages
man() {
  LESS_TERMCAP_mb=$'\e[1;31m' \
  LESS_TERMCAP_md=$'\e[1;36m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[01;33m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[1;32m' \
  command man "$@"
}

# ── Greeting ─────────────────────────────────────────────────
_powerkit_greeting() {
  local hour
  hour=$(date +%H)
  if   (( hour < 6  )); then greet="🌙 Good night"
  elif (( hour < 12 )); then greet="🌅 Good morning"
  elif (( hour < 18 )); then greet="☀️  Good afternoon"
  else                        greet="🌆 Good evening"
  fi
  echo -e "\033[1;36m  $greet! Type \033[1;33mpowerkit\033[1;36m to launch the toolkit.\033[0m"
}

# Uncomment to show greeting on shell start:
# _powerkit_greeting
