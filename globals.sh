#!/data/data/com.termux/files/usr/bin/bash
# ── Global Variables ─────────────────────────────────────────
VERSION="2.0.0"
AUTHOR="termux-powerkit contributors"
REPO="https://github.com/YOUR_USERNAME/termux-powerkit"

TERMUX_HOME="${HOME:-/data/data/com.termux/files/home}"
POWERKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$TERMUX_HOME/.powerkit/logs"
CONFIG_DIR="$TERMUX_HOME/.powerkit/config"
DATA_DIR="$TERMUX_HOME/.powerkit/data"
WORDLISTS_DIR="$TERMUX_HOME/.powerkit/wordlists"

# ── Ensure dirs exist ────────────────────────────────────────
mkdir -p "$LOG_DIR" "$CONFIG_DIR" "$DATA_DIR" "$WORDLISTS_DIR"

# ── Logging ──────────────────────────────────────────────────
log() {
  local level="$1"
  shift
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_DIR/powerkit.log"
}

log_info()  { log "INFO"  "$*"; }
log_warn()  { log "WARN"  "$*"; }
log_error() { log "ERROR" "$*"; }

# ── Utilities ────────────────────────────────────────────────
pause() {
  echo ""
  read -rp "$(echo -e "${DIM}  Press [Enter] to continue...${RESET}")"
}

confirm() {
  # Usage: confirm "Are you sure?" && do_thing
  local prompt="${1:-Are you sure?}"
  read -rp "$(echo -e "  ${YELLOW}${prompt} [y/N]:${RESET} ")" ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

require() {
  # Usage: require curl wget git
  local missing=()
  for cmd in "$@"; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${WARN} Missing tools: ${missing[*]}"
    echo -e "${INFO} Install with: pkg install ${missing[*]}"
    return 1
  fi
}

spinner() {
  local pid=$1
  local msg="${2:-Working...}"
  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % ${#spin} ))
    printf "\r  ${CYAN}${spin:$i:1}${RESET}  $msg"
    sleep 0.1
  done
  printf "\r  ${OK}  $msg\n"
}
