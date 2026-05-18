#!/data/data/com.termux/files/usr/bin/bash
# ============================================================
#   ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
#      ██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
#      ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝
#      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗
#      ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
#      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
#   P O W E R K I T  —  Termux Advanced Toolkit v2.0
# ============================================================
#  Author  : termux-powerkit contributors
#  License : MIT
#  Repo    : https://github.com/YOUR_USERNAME/termux-powerkit
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/colors.sh"
source "$SCRIPT_DIR/config/globals.sh"

# ── Banner ──────────────────────────────────────────────────
banner() {
  clear
  echo -e "${CYAN}"
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════╗
  ║      ⚡  TERMUX  P O W E R K I T  v2.0  ⚡          ║
  ╚══════════════════════════════════════════════════════╝
EOF
  echo -e "${YELLOW}  $(uname -o) | $(uname -r) | $(date '+%Y-%m-%d %H:%M')${RESET}"
  echo ""
}

# ── Main Menu ────────────────────────────────────────────────
main_menu() {
  banner
  echo -e "${WHITE}  ┌─────────────────────────────────────┐"
  echo -e "  │         MAIN MENU                   │"
  echo -e "  ├─────────────────────────────────────┤"
  echo -e "  │  ${GREEN}[1]${WHITE} 📡  Network Toolkit             │"
  echo -e "  │  ${GREEN}[2]${WHITE} 🖥️   System Info & Monitor       │"
  echo -e "  │  ${GREEN}[3]${WHITE} 🔐  Security & Pentesting        │"
  echo -e "  │  ${GREEN}[4]${WHITE} 📁  File Manager                 │"
  echo -e "  │  ${GREEN}[5]${WHITE} 📦  Package Manager              │"
  echo -e "  │  ${GREEN}[6]${WHITE} 🐍  Python Environment           │"
  echo -e "  │  ${GREEN}[7]${WHITE} 🌐  Web Tools                    │"
  echo -e "  │  ${GREEN}[8]${WHITE} 🔧  Dev Tools                    │"
  echo -e "  │  ${GREEN}[9]${WHITE} 🔑  SSH Manager                  │"
  echo -e "  │  ${GREEN}[0]${WHITE} ❌  Exit                         │"
  echo -e "  └─────────────────────────────────────┘${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select option:${RESET} ")" choice

  case "$choice" in
    1) bash "$SCRIPT_DIR/modules/network.sh" ;;
    2) bash "$SCRIPT_DIR/modules/sysinfo.sh" ;;
    3) bash "$SCRIPT_DIR/modules/security.sh" ;;
    4) bash "$SCRIPT_DIR/modules/filemanager.sh" ;;
    5) bash "$SCRIPT_DIR/modules/packages.sh" ;;
    6) bash "$SCRIPT_DIR/modules/python_env.sh" ;;
    7) bash "$SCRIPT_DIR/modules/webtools.sh" ;;
    8) bash "$SCRIPT_DIR/modules/devtools.sh" ;;
    9) bash "$SCRIPT_DIR/modules/ssh_manager.sh" ;;
    0) echo -e "${YELLOW}  Goodbye! ⚡${RESET}"; exit 0 ;;
    *) echo -e "${RED}  Invalid option.${RESET}"; sleep 1; main_menu ;;
  esac
}

# ── Entry Point ──────────────────────────────────────────────
check_termux() {
  if [[ ! -d /data/data/com.termux ]]; then
    echo -e "${RED}[!] This toolkit is designed for Termux on Android.${RESET}"
    echo -e "${YELLOW}[i] Some features may not work on standard Linux.${RESET}"
    sleep 2
  fi
}

check_termux
main_menu
