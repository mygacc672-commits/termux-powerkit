#!/data/data/com.termux/files/usr/bin/bash
# ── Dev Tools Module ─────────────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

dev_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   🔧  DEV TOOLS                 ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Git Manager"
  echo -e "  [2]  Node.js / npm"
  echo -e "  [3]  Compile & Run (gcc/g++/java)"
  echo -e "  [4]  JSON Pretty Printer"
  echo -e "  [5]  Base64 Encode/Decode"
  echo -e "  [6]  URL Encode/Decode"
  echo -e "  [7]  Generate UUID / Random"
  echo -e "  [8]  Cron Job Manager"
  echo -e "  [9]  Docker (if available)"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) dev_git ;;
    2) dev_node ;;
    3) dev_compile ;;
    4) dev_json ;;
    5) dev_base64 ;;
    6) dev_urlencode ;;
    7) dev_uuid ;;
    8) dev_cron ;;
    9) dev_docker ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; dev_menu ;;
  esac
}

dev_git() {
  require git || {
    echo -e "  ${INFO} Install: pkg install git"
    pause; dev_menu; return
  }
  clear
  echo -e "${CYAN}  ── Git Manager ─────────────────────────${RESET}"
  echo -e "  [1]  Clone repository"
  echo -e "  [2]  Quick commit & push"
  echo -e "  [3]  Show git log (graph)"
  echo -e "  [4]  Status & diff"
  echo -e "  [5]  Branch manager"
  echo -e "  [6]  Set global config (name/email)"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c

  case "$c" in
    1)
      read -rp "  Repo URL: " url
      read -rp "  Directory [auto]: " dir
      git clone "$url" ${dir:+"$dir"} 2>&1 | sed 's/^/  /'
      ;;
    2)
      read -rp "  Commit message: " msg
      git add -A && git commit -m "$msg" && git push 2>&1 | sed 's/^/  /'
      ;;
    3)
      git log --oneline --graph --decorate --all 2>&1 | head -30 | sed 's/^/  /'
      ;;
    4)
      echo -e "\n${CYAN}  ── Status ──${RESET}"
      git status 2>&1 | sed 's/^/  /'
      echo -e "\n${CYAN}  ── Diff ────${RESET}"
      git diff --stat 2>&1 | sed 's/^/  /'
      ;;
    5)
      echo -e "  Local branches:"
      git branch 2>&1 | sed 's/^/    /'
      echo -e "  Remote branches:"
      git branch -r 2>&1 | sed 's/^/    /'
      read -rp "  Switch to branch (or blank to skip): " branch
      [[ -n "$branch" ]] && git checkout "$branch" 2>&1 | sed 's/^/  /'
      ;;
    6)
      read -rp "  Name: " gname
      read -rp "  Email: " gemail
      git config --global user.name "$gname"
      git config --global user.email "$gemail"
      echo -e "  ${OK} Git config updated."
      ;;
  esac
  pause; dev_menu
}

dev_node() {
  require node npm || {
    echo -e "  ${INFO} Install: pkg install nodejs"
    pause; dev_menu; return
  }
  echo ""
  echo -e "  ${INFO} Node : $(node --version)"
  echo -e "  ${INFO} npm  : $(npm --version)"
  echo ""
  echo -e "  [1] Install package  [2] Run script  [3] Init project  [4] List globals"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  case "$c" in
    1) read -rp "  Package: " pkg; npm install "$pkg" 2>&1 | tail -5 ;;
    2) read -rp "  Script: " sc; node "$sc" ;;
    3) npm init -y ;;
    4) npm list -g --depth=0 2>&1 | sed 's/^/  /' ;;
  esac
  pause; dev_menu
}

dev_compile() {
  echo ""
  echo -e "  [1] C (gcc)  [2] C++ (g++)  [3] Java  [4] Rust (cargo)"
  read -rp "  $(echo -e "${CYAN}Language:${RESET} ")" lang
  read -rp "  Source file: " file
  [[ ! -f "$file" ]] && { echo -e "${RED}  File not found${RESET}"; pause; dev_menu; return; }
  local base="${file%.*}"
  case "$lang" in
    1) gcc "$file" -o "$base" && echo -e "  ${OK} Compiled: ./$base" ;;
    2) g++ "$file" -o "$base" && echo -e "  ${OK} Compiled: ./$base" ;;
    3) javac "$file" && echo -e "  ${OK} Compiled. Run: java ${base}" ;;
    4) cargo build --release 2>&1 | tail -5 ;;
  esac
  pause; dev_menu
}

dev_json() {
  echo ""
  echo -e "  [1] Pretty-print JSON file  [2] Pretty-print JSON string  [3] Minify JSON"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  case "$c" in
    1)
      read -rp "  File: " f
      python3 -m json.tool "$f" | sed 's/^/  /'
      ;;
    2)
      read -rp "  JSON string: " js
      echo "$js" | python3 -m json.tool | sed 's/^/  /'
      ;;
    3)
      read -rp "  File: " f
      python3 -c "import json,sys; print(json.dumps(json.load(open(sys.argv[1])), separators=(',',':')))" "$f"
      ;;
  esac
  pause; dev_menu
}

dev_base64() {
  echo ""
  echo -e "  [1] Encode text  [2] Decode text  [3] Encode file  [4] Decode file"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  case "$c" in
    1) read -rp "  Text: " t; echo -n "$t" | base64 ;;
    2) read -rp "  Base64: " t; echo "$t" | base64 -d; echo ;;
    3) read -rp "  File: " f; base64 "$f" ;;
    4) read -rp "  File: " f; read -rp "  Output: " o; base64 -d "$f" > "$o" && echo -e "  ${OK} Saved: $o" ;;
  esac
  pause; dev_menu
}

dev_urlencode() {
  echo ""
  echo -e "  [1] URL encode  [2] URL decode"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  read -rp "  Input: " inp
  python3 -c "
import sys
from urllib.parse import quote, unquote
c, s = sys.argv[1], sys.argv[2]
print(quote(s) if c=='1' else unquote(s))
" "$c" "$inp"
  pause; dev_menu
}

dev_uuid() {
  echo ""
  python3 -c "
import uuid, secrets, string
print('  UUID v4    :', uuid.uuid4())
print('  UUID v1    :', uuid.uuid1())
print('  Hex 32     :', secrets.token_hex(16))
print('  Hex 64     :', secrets.token_hex(32))
print('  URL-safe   :', secrets.token_urlsafe(32))
"
  pause; dev_menu
}

dev_cron() {
  echo ""
  echo -e "  [1] View crontab  [2] Edit crontab  [3] Add job  [4] List running crons"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  case "$c" in
    1) crontab -l 2>/dev/null | sed 's/^/  /' || echo "  No crons set." ;;
    2) crontab -e ;;
    3)
      echo -e "  ${INFO} Cron format: MIN HOUR DOM MON DOW COMMAND"
      read -rp "  Expression: " expr
      read -rp "  Command: " cmd
      (crontab -l 2>/dev/null; echo "$expr $cmd") | crontab -
      echo -e "  ${OK} Cron added."
      ;;
    4) ps aux | grep cron | grep -v grep | sed 's/^/  /' ;;
  esac
  pause; dev_menu
}

dev_docker() {
  if command -v docker &>/dev/null; then
    echo ""
    echo -e "  ${INFO} Docker: $(docker --version)"
    docker ps 2>&1 | sed 's/^/  /'
  else
    echo -e "\n  ${WARN} Docker not available on standard Termux."
    echo -e "  ${INFO} Try: pkg install proot-distro && proot-distro install ubuntu"
    echo -e "  ${INFO} Then install docker inside the Linux distro."
  fi
  pause; dev_menu
}

dev_menu
