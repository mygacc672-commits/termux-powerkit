#!/data/data/com.termux/files/usr/bin/bash
# ── Network Toolkit Module ───────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

net_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   📡  NETWORK TOOLKIT           ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  My IP Info (Public + Local)"
  echo -e "  [2]  Ping Test"
  echo -e "  [3]  Port Scanner (nmap)"
  echo -e "  [4]  DNS Lookup"
  echo -e "  [5]  Traceroute"
  echo -e "  [6]  WiFi Info"
  echo -e "  [7]  HTTP Headers Inspector"
  echo -e "  [8]  Download File (wget/curl)"
  echo -e "  [9]  Network Speed Test"
  echo -e "  [0]  ← Back to Main Menu${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) net_ip_info ;;
    2) net_ping ;;
    3) net_portscan ;;
    4) net_dns ;;
    5) net_traceroute ;;
    6) net_wifi ;;
    7) net_headers ;;
    8) net_download ;;
    9) net_speedtest ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; net_menu ;;
  esac
}

net_ip_info() {
  echo ""
  echo -e "${CYAN}  ── IP Information ─────────────────${RESET}"
  require curl || { pause; net_menu; return; }

  local pub_ip
  pub_ip=$(curl -s https://api.ipify.org 2>/dev/null || echo "Unavailable")
  echo -e "  ${OK} Public IP  : ${GREEN}${pub_ip}${RESET}"

  # Geolocation
  if [[ "$pub_ip" != "Unavailable" ]]; then
    local geo
    geo=$(curl -s "https://ipapi.co/${pub_ip}/json/" 2>/dev/null)
    echo -e "  ${OK} City       : $(echo "$geo" | grep -o '"city": *"[^"]*"' | cut -d'"' -f4)"
    echo -e "  ${OK} Country    : $(echo "$geo" | grep -o '"country_name": *"[^"]*"' | cut -d'"' -f4)"
    echo -e "  ${OK} ISP        : $(echo "$geo" | grep -o '"org": *"[^"]*"' | cut -d'"' -f4)"
  fi

  # Local IPs
  echo ""
  echo -e "  ${INFO} Network Interfaces:"
  ip addr 2>/dev/null | awk '/inet / { printf "    %-12s %s\n", $NF, $2 }' || \
    ifconfig 2>/dev/null | awk '/inet / { print "    " $2 }'

  log_info "IP info checked"
  pause; net_menu
}

net_ping() {
  echo ""
  read -rp "  $(echo -e "${CYAN}Target host [default: 8.8.8.8]:${RESET} ")" host
  host="${host:-8.8.8.8}"
  echo -e "\n  ${ARROW} Pinging ${host}...\n"
  ping -c 5 "$host" 2>&1 | sed 's/^/  /'
  log_info "Ping → $host"
  pause; net_menu
}

net_portscan() {
  require nmap || {
    echo -e "  ${INFO} Install: pkg install nmap"
    pause; net_menu; return
  }
  echo ""
  read -rp "  $(echo -e "${CYAN}Target IP/Host:${RESET} ")" target
  echo -e "  ${ARROW} Scan type:"
  echo -e "  [1] Quick scan (top 100 ports)"
  echo -e "  [2] Full TCP scan (1-65535)"
  echo -e "  [3] Service/Version detection"
  echo -e "  [4] UDP scan (top 20)"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" stype

  echo ""
  case "$stype" in
    1) nmap -F "$target" 2>&1 | sed 's/^/  /' ;;
    2) nmap -p- --open -T4 "$target" 2>&1 | sed 's/^/  /' ;;
    3) nmap -sV -sC "$target" 2>&1 | sed 's/^/  /' ;;
    4) nmap -sU --top-ports 20 "$target" 2>&1 | sed 's/^/  /' ;;
    *) echo -e "${RED}  Invalid choice${RESET}" ;;
  esac

  log_info "Port scan → $target"
  pause; net_menu
}

net_dns() {
  require dig nslookup || {
    echo -e "  ${INFO} Install: pkg install dnsutils"
    pause; net_menu; return
  }
  echo ""
  read -rp "  $(echo -e "${CYAN}Domain to lookup:${RESET} ")" domain
  echo ""
  echo -e "  ${ARROW} A Records:"
  dig +short A "$domain" 2>/dev/null | sed 's/^/    /'
  echo -e "  ${ARROW} MX Records:"
  dig +short MX "$domain" 2>/dev/null | sed 's/^/    /'
  echo -e "  ${ARROW} NS Records:"
  dig +short NS "$domain" 2>/dev/null | sed 's/^/    /'
  echo -e "  ${ARROW} TXT Records:"
  dig +short TXT "$domain" 2>/dev/null | sed 's/^/    /'
  echo -e "  ${ARROW} Reverse DNS (if IP):"
  dig +short -x "$domain" 2>/dev/null | sed 's/^/    /'

  log_info "DNS lookup → $domain"
  pause; net_menu
}

net_traceroute() {
  require traceroute || {
    echo -e "  ${INFO} Install: pkg install traceroute"
    pause; net_menu; return
  }
  echo ""
  read -rp "  $(echo -e "${CYAN}Target host:${RESET} ")" host
  echo ""
  traceroute "$host" 2>&1 | sed 's/^/  /'
  log_info "Traceroute → $host"
  pause; net_menu
}

net_wifi() {
  echo ""
  echo -e "${CYAN}  ── WiFi Information ───────────────${RESET}"
  termux-wifi-connectioninfo 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for k,v in d.items(): print(f'  {k:20}: {v}')
except:
    print('  Termux:API not installed. Run: pkg install termux-api')
"
  log_info "WiFi info checked"
  pause; net_menu
}

net_headers() {
  require curl || { pause; net_menu; return; }
  echo ""
  read -rp "  $(echo -e "${CYAN}URL (with https://):${RESET} ")" url
  echo ""
  curl -sI "$url" 2>&1 | sed 's/^/  /'
  log_info "HTTP headers → $url"
  pause; net_menu
}

net_download() {
  require curl wget || { pause; net_menu; return; }
  echo ""
  read -rp "  $(echo -e "${CYAN}URL to download:${RESET} ")" url
  read -rp "  $(echo -e "${CYAN}Save as [Enter for default]:${RESET} ")" fname
  echo ""
  if [[ -n "$fname" ]]; then
    wget -O "$fname" "$url" 2>&1 | tail -5
  else
    wget "$url" 2>&1 | tail -5
  fi
  log_info "Download → $url"
  pause; net_menu
}

net_speedtest() {
  if command -v speedtest-cli &>/dev/null; then
    echo -e "\n  ${ARROW} Running speed test...\n"
    speedtest-cli 2>&1 | sed 's/^/  /'
  elif command -v python3 &>/dev/null; then
    echo -e "  ${INFO} Installing speedtest-cli via pip..."
    pip install speedtest-cli --quiet
    speedtest-cli 2>&1 | sed 's/^/  /'
  else
    echo -e "  ${INFO} Install: pip install speedtest-cli"
  fi
  pause; net_menu
}

net_menu
