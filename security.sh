#!/data/data/com.termux/files/usr/bin/bash
# ── Security & Pentesting Module ─────────────────────────────
# ⚠ For EDUCATIONAL and AUTHORIZED testing ONLY
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

sec_menu() {
  clear
  echo -e "${RED}  ╔══════════════════════════════════════════╗"
  echo -e "  ║   🔐  SECURITY TOOLKIT                  ║"
  echo -e "  ║   ⚠  For authorized testing ONLY!       ║"
  echo -e "  ╚══════════════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Hash Generator & Cracker"
  echo -e "  [2]  Password Generator"
  echo -e "  [3]  Subdomain Finder"
  echo -e "  [4]  Directory Brute-Force (gobuster)"
  echo -e "  [5]  SQL Injection Tester (sqlmap)"
  echo -e "  [6]  Metasploit Framework"
  echo -e "  [7]  Hydra Login Brute-Force"
  echo -e "  [8]  Recon: WHOIS + Shodan"
  echo -e "  [9]  SSL/TLS Inspector"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) sec_hash ;;
    2) sec_passgen ;;
    3) sec_subdomain ;;
    4) sec_dirbust ;;
    5) sec_sqlmap ;;
    6) sec_metasploit ;;
    7) sec_hydra ;;
    8) sec_recon ;;
    9) sec_ssl ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; sec_menu ;;
  esac
}

sec_hash() {
  clear
  echo -e "${CYAN}  ── Hash Tools ──────────────────────────${RESET}"
  echo -e "  [1] Generate hash of text"
  echo -e "  [2] Generate hash of file"
  echo -e "  [3] Crack MD5 hash (wordlist)"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c

  case "$c" in
    1)
      read -rp "  Text: " txt
      echo ""
      echo -e "  MD5    : $(echo -n "$txt" | md5sum | cut -d' ' -f1)"
      echo -e "  SHA1   : $(echo -n "$txt" | sha1sum | cut -d' ' -f1)"
      echo -e "  SHA256 : $(echo -n "$txt" | sha256sum | cut -d' ' -f1)"
      echo -e "  SHA512 : $(echo -n "$txt" | sha512sum | cut -d' ' -f1)"
      ;;
    2)
      read -rp "  File path: " fpath
      [[ -f "$fpath" ]] || { echo -e "${RED}  File not found${RESET}"; pause; sec_menu; return; }
      echo ""
      echo -e "  MD5    : $(md5sum "$fpath")"
      echo -e "  SHA1   : $(sha1sum "$fpath")"
      echo -e "  SHA256 : $(sha256sum "$fpath")"
      ;;
    3)
      read -rp "  MD5 hash to crack: " hash
      read -rp "  Wordlist path [~/.powerkit/wordlists/rockyou.txt]: " wl
      wl="${wl:-$WORDLISTS_DIR/rockyou.txt}"
      if [[ ! -f "$wl" ]]; then
        echo -e "  ${WARN} Wordlist not found. Download: curl -L https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -o $wl"
      else
        echo -e "  ${ARROW} Cracking..."
        while IFS= read -r word; do
          if [[ "$(echo -n "$word" | md5sum | cut -d' ' -f1)" == "$hash" ]]; then
            echo -e "  ${OK} FOUND: ${GREEN}${word}${RESET}"
            break
          fi
        done < "$wl"
      fi
      ;;
  esac
  pause; sec_menu
}

sec_passgen() {
  clear
  echo -e "${CYAN}  ── Password Generator ──────────────────${RESET}\n"
  read -rp "  Length [default 20]: " len
  read -rp "  Count  [default 5]:  " cnt
  len="${len:-20}"; cnt="${cnt:-5}"

  echo ""
  echo -e "  ${INFO} Generated passwords:"
  echo ""
  for i in $(seq 1 "$cnt"); do
    # Generate using /dev/urandom
    LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()-_=+[]{}|;:,.<>?' \
      < /dev/urandom | head -c "$len"
    echo ""
  done
  echo ""
  pause; sec_menu
}

sec_subdomain() {
  echo ""
  read -rp "  $(echo -e "${CYAN}Domain (e.g. example.com):${RESET} ")" domain
  require curl || { pause; sec_menu; return; }

  echo -e "\n  ${ARROW} Finding subdomains via crt.sh...\n"
  curl -s "https://crt.sh/?q=%25.${domain}&output=json" 2>/dev/null | \
    python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    subs = sorted({entry['name_value'].strip() for entry in data if 'name_value' in entry})
    for s in subs:
        for line in s.split('\n'):
            if line.startswith('*.'):
                line = line[2:]
            print(f'  {line}')
    print(f'\n  Total: {len(subs)} found')
except Exception as e:
    print(f'  Error: {e}')
"
  log_info "Subdomain enum → $domain"
  pause; sec_menu
}

sec_dirbust() {
  if ! command -v gobuster &>/dev/null; then
    echo -e "  ${INFO} gobuster not found."
    echo -e "  ${INFO} Install: pkg install golang && go install github.com/OJ/gobuster/v3@latest"
    pause; sec_menu; return
  fi
  read -rp "  $(echo -e "${CYAN}URL (https://target.com):${RESET} ")" url
  local wl="/usr/share/wordlists/dirb/common.txt"
  [[ ! -f "$wl" ]] && wl="$WORDLISTS_DIR/common.txt"
  echo ""
  gobuster dir -u "$url" -w "$wl" -t 50 2>&1 | sed 's/^/  /'
  pause; sec_menu
}

sec_sqlmap() {
  if ! command -v sqlmap &>/dev/null; then
    echo -e "  ${INFO} Install: pip install sqlmap"
    read -rp "  Install now? [y/N]: " yn
    [[ "$yn" =~ ^[Yy]$ ]] && pip install sqlmap
    pause; sec_menu; return
  fi
  read -rp "  $(echo -e "${CYAN}Target URL with parameter (e.g. http://site.com/p.php?id=1):${RESET} ")" url
  sqlmap -u "$url" --batch --level=2 2>&1 | sed 's/^/  /'
  pause; sec_menu
}

sec_metasploit() {
  if command -v msfconsole &>/dev/null; then
    msfconsole
  else
    echo -e "\n  ${INFO} Metasploit install on Termux:"
    echo -e "  1. pkg install unstable-repo"
    echo -e "  2. pkg install metasploit"
    echo -e "  3. msfconsole"
  fi
  pause; sec_menu
}

sec_hydra() {
  if ! command -v hydra &>/dev/null; then
    echo -e "  ${INFO} Install: pkg install hydra"
    pause; sec_menu; return
  fi
  echo ""
  read -rp "  Target IP: " ip
  read -rp "  Service [ssh/ftp/http-get/smb]: " svc
  read -rp "  Username: " user
  read -rp "  Wordlist [~/.powerkit/wordlists/rockyou.txt]: " wl
  wl="${wl:-$WORDLISTS_DIR/rockyou.txt}"
  echo ""
  hydra -l "$user" -P "$wl" "$ip" "$svc" -t 4 2>&1 | sed 's/^/  /'
  pause; sec_menu
}

sec_recon() {
  require whois curl || { pause; sec_menu; return; }
  echo ""
  read -rp "  $(echo -e "${CYAN}Target domain or IP:${RESET} ")" target
  echo -e "\n${CYAN}  ── WHOIS ──────────────────────────────${RESET}\n"
  whois "$target" 2>&1 | grep -v '^%\|^#' | grep -E '\S' | head -30 | sed 's/^/  /'
  echo ""
  echo -e "${CYAN}  ── Shodan Quick Lookup ────────────────${RESET}\n"
  curl -s "https://internetdb.shodan.io/$target" 2>/dev/null | \
    python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(f'  Open Ports : {d.get(\"ports\", [])}')
    print(f'  Hostnames  : {d.get(\"hostnames\", [])}')
    print(f'  Tags       : {d.get(\"tags\", [])}')
    print(f'  Vulns      : {d.get(\"vulns\", [])}')
except: print('  No data found')
"
  log_info "Recon → $target"
  pause; sec_menu
}

sec_ssl() {
  require openssl || { pause; sec_menu; return; }
  echo ""
  read -rp "  $(echo -e "${CYAN}Domain:${RESET} ")" domain
  echo ""
  echo -e "  ${ARROW} Certificate info:\n"
  echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null | \
    openssl x509 -noout -subject -issuer -dates -fingerprint 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  ${ARROW} Supported ciphers:\n"
  nmap --script ssl-enum-ciphers -p 443 "$domain" 2>/dev/null | grep -E 'TLS|SSL|cipher' | sed 's/^/  /'
  pause; sec_menu
}

sec_menu
