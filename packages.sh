#!/data/data/com.termux/files/usr/bin/bash
# ── Package Manager Module ───────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

pkg_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   📦  PACKAGE MANAGER           ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Update & Upgrade all"
  echo -e "  [2]  Search package"
  echo -e "  [3]  Install package(s)"
  echo -e "  [4]  Remove package"
  echo -e "  [5]  Show package info"
  echo -e "  [6]  List installed packages"
  echo -e "  [7]  Essential tools installer"
  echo -e "  [8]  Hacking tools installer"
  echo -e "  [9]  Repos manager"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) pkg_update ;;
    2) pkg_search ;;
    3) pkg_install ;;
    4) pkg_remove ;;
    5) pkg_info ;;
    6) pkg_list ;;
    7) pkg_essentials ;;
    8) pkg_hacking ;;
    9) pkg_repos ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; pkg_menu ;;
  esac
}

pkg_update() {
  echo -e "\n  ${ARROW} Updating package lists...\n"
  apt update 2>&1 | tail -3
  echo -e "\n  ${ARROW} Upgrading packages...\n"
  apt upgrade -y 2>&1 | tail -10
  echo -e "\n  ${OK} System updated!"
  pause; pkg_menu
}

pkg_search() {
  read -rp "  $(echo -e "\n  ${CYAN}Search term:${RESET} ")" term
  apt search "$term" 2>/dev/null | grep -v "WARNING\|Listing" | sed 's/^/  /' | head -40
  pause; pkg_menu
}

pkg_install() {
  read -rp "  $(echo -e "\n  ${CYAN}Package(s):${RESET} ")" pkgs
  apt install -y $pkgs 2>&1 | tail -10
  pause; pkg_menu
}

pkg_remove() {
  read -rp "  $(echo -e "\n  ${CYAN}Package to remove:${RESET} ")" pkg
  confirm "Remove $pkg?" && apt remove -y "$pkg" 2>&1 | tail -5
  pause; pkg_menu
}

pkg_info() {
  read -rp "  $(echo -e "\n  ${CYAN}Package name:${RESET} ")" pkg
  apt show "$pkg" 2>/dev/null | sed 's/^/  /'
  pause; pkg_menu
}

pkg_list() {
  echo ""
  dpkg -l 2>/dev/null | grep '^ii' | awk '{printf "  %-30s %s\n", $2, $3}' | less
  pkg_menu
}

pkg_essentials() {
  local essentials=(
    git curl wget python python2 python-pip
    nodejs nano vim neovim tmux htop
    openssh net-tools nmap dnsutils
    zip unzip tar pv bc jq tree
    ffmpeg imagemagick tsu termux-api
    clang cmake make rust golang
  )

  echo -e "\n  ${INFO} Installing essential tools...\n"
  for p in "${essentials[@]}"; do
    echo -ne "  ${ARROW} Installing $p..."
    apt install -y "$p" -qq 2>/dev/null && echo -e " ${OK}" || echo -e " ${WARN} (skip)"
  done
  echo -e "\n  ${OK} Essentials installed!"
  pause; pkg_menu
}

pkg_hacking() {
  echo -e "${RED}\n  ⚠  For authorized/educational use ONLY${RESET}\n"
  confirm "Proceed with hacking tools install?" || { pkg_menu; return; }

  local tools=(
    nmap hydra sqlmap metasploit
    aircrack-ng john hashcat
    wireshark tcpdump netcat
    gobuster nikto whatweb
    wifite mdk3 hostapd
  )

  echo ""
  for t in "${tools[@]}"; do
    echo -ne "  ${ARROW} Installing $t..."
    apt install -y "$t" -qq 2>/dev/null && echo -e " ${OK}" || \
      pip install "$t" -q 2>/dev/null && echo -e " ${OK} (pip)" || \
      echo -e " ${WARN} (unavailable)"
  done
  echo -e "\n  ${OK} Done!"
  pause; pkg_menu
}

pkg_repos() {
  clear
  echo -e "${CYAN}  ── Repository Manager ──────────────────${RESET}\n"
  echo -e "  Current sources:"
  cat "$PREFIX/etc/apt/sources.list" 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  [1] Add unstable repo  [2] Add science repo  [3] Run termux-change-repo"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  case "$c" in
    1)
      echo "deb https://packages.termux.dev/apt/termux-main unstable main" >> \
        "$PREFIX/etc/apt/sources.list.d/unstable.list"
      echo -e "  ${OK} Unstable repo added."
      ;;
    2)
      pkg install termux-science-repo -y 2>&1 | tail -3
      ;;
    3)
      termux-change-repo
      ;;
  esac
  pause; pkg_menu
}

pkg_menu
