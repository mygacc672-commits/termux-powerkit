#!/data/data/com.termux/files/usr/bin/bash
# ── System Info & Monitor Module ─────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

sys_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   🖥️   SYSTEM INFO & MONITOR    ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Full System Overview"
  echo -e "  [2]  CPU Info"
  echo -e "  [3]  Memory Usage"
  echo -e "  [4]  Storage / Disk Usage"
  echo -e "  [5]  Battery Status"
  echo -e "  [6]  Running Processes (top 20)"
  echo -e "  [7]  Live Process Monitor"
  echo -e "  [8]  Termux Environment Info"
  echo -e "  [9]  Temperature & Sensors"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) sys_overview ;;
    2) sys_cpu ;;
    3) sys_memory ;;
    4) sys_storage ;;
    5) sys_battery ;;
    6) sys_processes ;;
    7) sys_live ;;
    8) sys_termux ;;
    9) sys_temp ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; sys_menu ;;
  esac
}

sys_overview() {
  clear
  echo -e "${CYAN}  ══ SYSTEM OVERVIEW ════════════════════════════════${RESET}"
  echo ""

  # Basic info
  echo -e "  ${INFO} ${BOLD}Device / OS${RESET}"
  echo -e "    Kernel   : $(uname -r)"
  echo -e "    Arch     : $(uname -m)"
  echo -e "    OS       : $(uname -o)"
  echo -e "    Hostname : $(hostname 2>/dev/null || echo 'N/A')"
  echo -e "    Uptime   : $(uptime -p 2>/dev/null || uptime)"
  echo ""

  # CPU
  echo -e "  ${INFO} ${BOLD}CPU${RESET}"
  local cpumodel
  cpumodel=$(grep -m1 'Hardware\|model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs)
  echo -e "    Model    : ${cpumodel:-Unknown}"
  echo -e "    Cores    : $(nproc 2>/dev/null || grep -c processor /proc/cpuinfo)"
  echo -e "    Load     : $(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')"
  echo ""

  # Memory
  echo -e "  ${INFO} ${BOLD}Memory${RESET}"
  free -h 2>/dev/null | awk '
    /Mem:/ { printf "    RAM      : %s used / %s total\n", $3, $2 }
    /Swap:/ { printf "    Swap     : %s used / %s total\n", $3, $2 }
  '
  echo ""

  # Storage
  echo -e "  ${INFO} ${BOLD}Storage${RESET}"
  df -h /data/data/com.termux 2>/dev/null | awk 'NR==2 { printf "    Termux   : %s used / %s total (%s)\n", $3, $2, $5 }'
  df -h /sdcard 2>/dev/null | awk 'NR==2 { printf "    SDCard   : %s used / %s total (%s)\n", $3, $2, $5 }'
  echo ""

  log_info "System overview displayed"
  pause; sys_menu
}

sys_cpu() {
  clear
  echo -e "${CYAN}  ══ CPU INFORMATION ════════════════════════════════${RESET}\n"
  grep -E 'processor|model name|Hardware|BogoMIPS|cpu MHz|cache size|cpu cores' \
    /proc/cpuinfo 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  ${INFO} Current CPU Usage:"
  top -bn1 2>/dev/null | grep '%Cpu\|Cpu(s)' | sed 's/^/  /' || \
    cat /proc/stat | awk '/^cpu / {
      total=$2+$3+$4+$5; used=$2+$3+$4
      printf "  CPU usage: %.1f%%\n", used/total*100
    }'
  pause; sys_menu
}

sys_memory() {
  clear
  echo -e "${CYAN}  ══ MEMORY USAGE ════════════════════════════════════${RESET}\n"
  free -h 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  ${INFO} Top 10 memory consumers:"
  ps aux 2>/dev/null --sort=-%mem | head -11 | \
    awk 'NR==1 {printf "  %-10s %-6s %-6s %s\n", "USER", "%CPU", "%MEM", "COMMAND"}
         NR>1  {printf "  %-10s %-6s %-6s %s\n", $1, $3, $4, $11}' || \
    ps -eo pid,user,%mem,comm 2>/dev/null | sort -k3 -rn | head -11 | sed 's/^/  /'
  pause; sys_menu
}

sys_storage() {
  clear
  echo -e "${CYAN}  ══ DISK / STORAGE ══════════════════════════════════${RESET}\n"
  df -h 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  ${INFO} Termux home directory size:"
  du -sh "$HOME" 2>/dev/null | sed 's/^/  /'
  pause; sys_menu
}

sys_battery() {
  clear
  echo -e "${CYAN}  ══ BATTERY STATUS ══════════════════════════════════${RESET}\n"
  if command -v termux-battery-status &>/dev/null; then
    termux-battery-status 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    icons = {'CHARGING':'🔌','DISCHARGING':'🔋','FULL':'⚡','NOT_CHARGING':'🔌'}
    st = d.get('status','?')
    pct = d.get('percentage',0)
    bar = '█' * (pct//10) + '░' * (10 - pct//10)
    print(f'  Status      : {icons.get(st,\"\")} {st}')
    print(f'  Level       : {pct}%  [{bar}]')
    print(f'  Temperature : {d.get(\"temperature\",\"N/A\")}°C')
    print(f'  Health      : {d.get(\"health\",\"N/A\")}')
    print(f'  Plugged     : {d.get(\"plugged\",\"N/A\")}')
except Exception as e:
    print(f'  Error: {e}')
"
  else
    echo -e "  ${WARN} Install Termux:API: pkg install termux-api"
    echo -e "  ${INFO} Also install the Termux:API app from F-Droid"
  fi
  pause; sys_menu
}

sys_processes() {
  clear
  echo -e "${CYAN}  ══ TOP PROCESSES ═══════════════════════════════════${RESET}\n"
  ps -eo pid,user,pcpu,pmem,comm 2>/dev/null | \
    sort -k3 -rn | head -21 | \
    awk 'NR==1 {printf "  %-8s %-12s %-6s %-6s %s\n","PID","USER","%CPU","%MEM","CMD"}
         NR>1  {printf "  %-8s %-12s %-6s %-6s %s\n",$1,$2,$3,$4,$5}'
  pause; sys_menu
}

sys_live() {
  echo -e "  ${INFO} Launching live monitor (q to quit)..."
  sleep 1
  top
  sys_menu
}

sys_termux() {
  clear
  echo -e "${CYAN}  ══ TERMUX ENVIRONMENT ══════════════════════════════${RESET}\n"
  echo -e "  HOME         : $HOME"
  echo -e "  PREFIX       : ${PREFIX:-/data/data/com.termux/files/usr}"
  echo -e "  SHELL        : $SHELL"
  echo -e "  TERM         : ${TERM:-unknown}"
  echo -e "  COLORTERM    : ${COLORTERM:-unknown}"
  echo -e "  PATH         : $PATH" | fold -s -w 70 | sed '2,$s/^/               /'
  echo ""
  echo -e "  ${INFO} Installed packages count:"
  dpkg -l 2>/dev/null | grep -c '^ii' | awk '{print "  "$1 " packages installed"}'
  echo ""
  echo -e "  ${INFO} Shell version: $($SHELL --version 2>&1 | head -1)"
  pause; sys_menu
}

sys_temp() {
  clear
  echo -e "${CYAN}  ══ TEMPERATURE / SENSORS ══════════════════════════${RESET}\n"
  # Try thermal zones
  if ls /sys/class/thermal/thermal_zone*/temp &>/dev/null; then
    for zone in /sys/class/thermal/thermal_zone*/; do
      local name type temp
      type=$(cat "${zone}type" 2>/dev/null)
      temp=$(cat "${zone}temp" 2>/dev/null)
      if [[ -n "$temp" ]]; then
        temp_c=$(echo "scale=1; $temp/1000" | bc 2>/dev/null || echo "${temp:0:-3}.0")
        printf "  %-25s : %s°C\n" "$type" "$temp_c"
      fi
    done
  else
    echo -e "  ${WARN} Thermal zone data not accessible"
  fi
  pause; sys_menu
}

sys_menu
