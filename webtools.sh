#!/data/data/com.termux/files/usr/bin/bash
# ── Web Tools Module ─────────────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

web_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   🌐  WEB TOOLS                 ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  cURL request builder"
  echo -e "  [2]  Website availability checker"
  echo -e "  [3]  WhoIs + IP Geo"
  echo -e "  [4]  Website crawler (wget mirror)"
  echo -e "  [5]  API tester (REST)"
  echo -e "  [6]  Web scraper (Python)"
  echo -e "  [7]  YouTube-DL / yt-dlp"
  echo -e "  [8]  Wayback Machine lookup"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) web_curl ;;
    2) web_check ;;
    3) web_whois ;;
    4) web_crawl ;;
    5) web_api ;;
    6) web_scrape ;;
    7) web_ytdl ;;
    8) web_wayback ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; web_menu ;;
  esac
}

web_curl() {
  require curl || { pause; web_menu; return; }
  echo ""
  read -rp "  URL: " url
  echo -e "  Method [GET/POST/PUT/DELETE] (default GET): "; read -r method
  method="${method:-GET}"

  local headers=() data=""
  read -rp "  Add header? (e.g. Authorization: Bearer TOKEN) [blank skip]: " h
  [[ -n "$h" ]] && headers+=(-H "$h")

  if [[ "$method" != "GET" ]]; then
    read -rp "  Request body (JSON): " data
  fi

  echo ""
  if [[ -n "$data" ]]; then
    curl -s -X "$method" "${headers[@]}" -H "Content-Type: application/json" \
      -d "$data" "$url" | python3 -m json.tool 2>/dev/null || echo "$?"
  else
    curl -s -X "$method" "${headers[@]}" "$url" | python3 -m json.tool 2>/dev/null
  fi
  pause; web_menu
}

web_check() {
  require curl || { pause; web_menu; return; }
  echo ""
  read -rp "  URLs (space-separated) or file path: " input

  check_url() {
    local url="$1"
    local code
    code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url")
    local status_color="${GREEN}"
    [[ "$code" -ge 400 ]] && status_color="${RED}"
    [[ "$code" == "000" ]] && status_color="${RED}" && code="OFFLINE"
    echo -e "  $status_color[$code]${RESET} $url"
  }

  if [[ -f "$input" ]]; then
    while IFS= read -r url; do
      [[ -n "$url" ]] && check_url "$url"
    done < "$input"
  else
    for url in $input; do
      check_url "$url"
    done
  fi
  pause; web_menu
}

web_whois() {
  require whois curl || { pause; web_menu; return; }
  echo ""
  read -rp "  Domain or IP: " target
  echo -e "\n${CYAN}  ── WHOIS ──────────────${RESET}"
  whois "$target" 2>/dev/null | grep -v '^%\|^#\|^$' | head -25 | sed 's/^/  /'
  echo -e "\n${CYAN}  ── Geo IP ─────────────${RESET}"
  curl -s "https://ipapi.co/$target/json/" 2>/dev/null | \
    python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    fields = ['ip','city','region','country_name','org','timezone','latitude','longitude']
    for f in fields:
        if f in d: print(f'  {f:15}: {d[f]}')
except: pass
"
  pause; web_menu
}

web_crawl() {
  require wget || { pause; web_menu; return; }
  echo ""
  read -rp "  URL to mirror: " url
  read -rp "  Depth [2]: " depth
  depth="${depth:-2}"
  echo -e "\n  ${ARROW} Mirroring site...\n"
  wget --mirror --convert-links --adjust-extension \
    --page-requisites --no-parent \
    -l "$depth" "$url" 2>&1 | tail -10
  pause; web_menu
}

web_api() {
  echo ""
  echo -e "  Quick REST API tester"
  read -rp "  Endpoint URL: " url
  read -rp "  Method [GET]: " method
  method="${method:-GET}"
  read -rp "  Token (Bearer, or blank): " token
  read -rp "  Body JSON (or blank): " body
  echo ""

  local cmd="curl -s -X $method"
  [[ -n "$token" ]] && cmd="$cmd -H 'Authorization: Bearer $token'"
  cmd="$cmd -H 'Content-Type: application/json'"
  [[ -n "$body" ]] && cmd="$cmd -d '$body'"
  cmd="$cmd '$url'"

  eval "$cmd" | python3 -m json.tool 2>/dev/null || eval "$cmd"
  pause; web_menu
}

web_scrape() {
  require python3 || { pause; web_menu; return; }
  echo ""
  read -rp "  URL to scrape: " url
  read -rp "  CSS selector [default: p]: " selector
  selector="${selector:-p}"
  python3 -c "
import urllib.request
from html.parser import HTMLParser

class Scraper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.capture = False
        self.tag = ''
        self.results = []
        self.buffer = ''
    def handle_starttag(self, tag, attrs):
        if tag == '$selector'.split(':')[0]:
            self.capture = True
            self.buffer = ''
    def handle_endtag(self, tag):
        if tag == '$selector'.split(':')[0] and self.capture:
            self.capture = False
            t = self.buffer.strip()
            if t: self.results.append(t)
    def handle_data(self, data):
        if self.capture:
            self.buffer += data

try:
    req = urllib.request.Request('$url', headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req, timeout=10).read().decode('utf-8', errors='ignore')
    s = Scraper()
    s.feed(html)
    for r in s.results[:20]:
        print('  ' + r[:100])
    print(f'\n  Total matches: {len(s.results)}')
except Exception as e:
    print(f'  Error: {e}')
"
  pause; web_menu
}

web_ytdl() {
  if command -v yt-dlp &>/dev/null; then
    local tool="yt-dlp"
  elif command -v youtube-dl &>/dev/null; then
    local tool="youtube-dl"
  else
    echo -e "  ${INFO} Installing yt-dlp..."
    pip install yt-dlp
    local tool="yt-dlp"
  fi

  echo ""
  read -rp "  URL: " url
  echo -e "  [1] Download video  [2] Audio only (mp3)  [3] List formats"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  echo ""
  case "$c" in
    1) $tool "$url" 2>&1 | tail -10 ;;
    2) $tool -x --audio-format mp3 "$url" 2>&1 | tail -10 ;;
    3) $tool -F "$url" 2>&1 | sed 's/^/  /' ;;
  esac
  pause; web_menu
}

web_wayback() {
  require curl || { pause; web_menu; return; }
  echo ""
  read -rp "  URL to check: " url
  echo -e "\n  ${ARROW} Querying Wayback Machine...\n"
  curl -s "https://archive.org/wayback/available?url=$url" | \
    python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    s = d.get('archived_snapshots',{}).get('closest',{})
    if s.get('available'):
        print(f'  Status    : {s[\"status\"]}')
        print(f'  Timestamp : {s[\"timestamp\"]}')
        print(f'  URL       : {s[\"url\"]}')
    else:
        print('  No snapshots found.')
except: print('  Error fetching data.')
"
  pause; web_menu
}

web_menu
