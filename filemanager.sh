#!/data/data/com.termux/files/usr/bin/bash
# ── File Manager Module ──────────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

fm_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   📁  FILE MANAGER              ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo -e "  ${DIM}Current: $(pwd)${RESET}\n"
  echo -e "${WHITE}  [1]  Browse / Navigate"
  echo -e "  [2]  Search files"
  echo -e "  [3]  Archive (zip/tar)"
  echo -e "  [4]  Extract archive"
  echo -e "  [5]  File info & permissions"
  echo -e "  [6]  Bulk rename"
  echo -e "  [7]  Find & delete duplicates"
  echo -e "  [8]  Sync to storage"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) fm_browse ;;
    2) fm_search ;;
    3) fm_archive ;;
    4) fm_extract ;;
    5) fm_info ;;
    6) fm_rename ;;
    7) fm_dedup ;;
    8) fm_sync ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; fm_menu ;;
  esac
}

fm_browse() {
  if command -v mc &>/dev/null; then
    mc; fm_menu; return
  fi
  echo ""
  echo -e "${CYAN}  ── File Browser ────────────────────────${RESET}"
  local dir="${1:-$HOME}"
  ls -lAh --color=always "$dir" 2>/dev/null | sed 's/^/  /'
  echo ""
  read -rp "  Navigate to (path or blank for home): " newdir
  [[ -n "$newdir" ]] && cd "$newdir" 2>/dev/null && fm_browse "$(pwd)" || fm_browse
}

fm_search() {
  echo ""
  read -rp "  Search in directory [$(pwd)]: " sdir
  sdir="${sdir:-.}"
  read -rp "  Filename pattern (e.g. *.py, secret): " pattern
  read -rp "  Content grep (blank to skip): " content
  echo ""

  if [[ -n "$content" ]]; then
    grep -rl "$content" "$sdir" 2>/dev/null | grep -i "$pattern" | sed 's/^/  /'
  else
    find "$sdir" -name "*$pattern*" 2>/dev/null | head -50 | sed 's/^/  /'
  fi
  pause; fm_menu
}

fm_archive() {
  echo ""
  echo -e "  [1] Create zip  [2] Create tar.gz  [3] Create tar.bz2"
  read -rp "  $(echo -e "${CYAN}Format:${RESET} ")" fmt
  read -rp "  Output name (without extension): " name
  read -rp "  Files/dirs to add (space-separated): " files

  case "$fmt" in
    1) zip -r "${name}.zip" $files && echo -e "  ${OK} Created: ${name}.zip" ;;
    2) tar czf "${name}.tar.gz" $files && echo -e "  ${OK} Created: ${name}.tar.gz" ;;
    3) tar cjf "${name}.tar.bz2" $files && echo -e "  ${OK} Created: ${name}.tar.bz2" ;;
  esac
  pause; fm_menu
}

fm_extract() {
  echo ""
  read -rp "  Archive file: " file
  read -rp "  Output dir [current]: " outdir
  outdir="${outdir:-.}"

  [[ ! -f "$file" ]] && { echo -e "${RED}  File not found${RESET}"; pause; fm_menu; return; }

  case "$file" in
    *.zip)     unzip "$file" -d "$outdir" ;;
    *.tar.gz)  tar xzf "$file" -C "$outdir" ;;
    *.tar.bz2) tar xjf "$file" -C "$outdir" ;;
    *.tar.xz)  tar xJf "$file" -C "$outdir" ;;
    *.rar)     unrar x "$file" "$outdir" ;;
    *.7z)      7z x "$file" -o"$outdir" ;;
    *)         echo -e "  ${WARN} Unknown archive format" ;;
  esac
  echo -e "  ${OK} Extracted to $outdir"
  pause; fm_menu
}

fm_info() {
  echo ""
  read -rp "  File/directory path: " path
  [[ ! -e "$path" ]] && { echo -e "${RED}  Not found${RESET}"; pause; fm_menu; return; }
  echo ""
  ls -lah "$path" | sed 's/^/  /'
  echo ""
  file "$path" 2>/dev/null | sed 's/^/  /'
  stat "$path" 2>/dev/null | sed 's/^/  /'
  echo ""
  echo -e "  ${INFO} Permissions: $(stat -c '%a %n' "$path" 2>/dev/null)"
  echo -e "  ${INFO} Owner:       $(stat -c '%U:%G' "$path" 2>/dev/null)"
  pause; fm_menu
}

fm_rename() {
  echo ""
  read -rp "  Directory: " dir
  read -rp "  Find string: " find_str
  read -rp "  Replace with: " replace_str
  echo ""
  local count=0
  while IFS= read -r -d '' f; do
    local base dir_part newname
    base="$(basename "$f")"
    dir_part="$(dirname "$f")"
    newname="${base//$find_str/$replace_str}"
    if [[ "$base" != "$newname" ]]; then
      mv "$f" "$dir_part/$newname"
      echo -e "  ${OK} $base → $newname"
      ((count++))
    fi
  done < <(find "$dir" -maxdepth 1 -type f -print0 2>/dev/null)
  echo -e "\n  Renamed $count files."
  pause; fm_menu
}

fm_dedup() {
  require md5sum || { pause; fm_menu; return; }
  echo ""
  read -rp "  Scan directory: " dir
  echo -e "\n  ${ARROW} Finding duplicates...\n"
  declare -A seen
  while IFS= read -r -d '' f; do
    local hash
    hash=$(md5sum "$f" | cut -d' ' -f1)
    if [[ -n "${seen[$hash]+x}" ]]; then
      echo -e "  ${WARN} DUPLICATE: $f"
      echo -e "  ${DIM}    same as: ${seen[$hash]}${RESET}"
    else
      seen[$hash]="$f"
    fi
  done < <(find "$dir" -type f -print0 2>/dev/null)
  echo -e "\n  ${OK} Scan complete."
  pause; fm_menu
}

fm_sync() {
  require rsync || {
    echo -e "  ${INFO} Install: pkg install rsync"
    pause; fm_menu; return
  }
  echo ""
  read -rp "  Source: " src
  read -rp "  Destination (or user@host:/path for remote): " dst
  echo -e "\n  ${ARROW} Syncing...\n"
  rsync -avh --progress "$src" "$dst" 2>&1 | tail -15
  pause; fm_menu
}

fm_menu
