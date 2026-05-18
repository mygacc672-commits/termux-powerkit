#!/data/data/com.termux/files/usr/bin/bash
# ── SSH Manager Module ───────────────────────────────────────
source "$(dirname "$0")/config/colors.sh"
source "$(dirname "$0")/config/globals.sh"

SSH_HOSTS_FILE="$CONFIG_DIR/ssh_hosts.conf"
touch "$SSH_HOSTS_FILE"

ssh_menu() {
  clear
  echo -e "${CYAN}  ╔══════════════════════════════════╗"
  echo -e "  ║   🔑  SSH MANAGER               ║"
  echo -e "  ╚══════════════════════════════════╝${RESET}"
  echo ""
  echo -e "${WHITE}  [1]  Saved Hosts (connect)"
  echo -e "  [2]  Add new host"
  echo -e "  [3]  Remove host"
  echo -e "  [4]  Generate SSH keypair"
  echo -e "  [5]  Copy public key to server"
  echo -e "  [6]  Start SSH server (on this device)"
  echo -e "  [7]  Port forward / Tunnel"
  echo -e "  [0]  ← Back${RESET}"
  echo ""
  read -rp "  $(echo -e "${CYAN}Select:${RESET} ")" opt

  case "$opt" in
    1) ssh_connect ;;
    2) ssh_add_host ;;
    3) ssh_remove_host ;;
    4) ssh_keygen ;;
    5) ssh_copy_key ;;
    6) ssh_start_server ;;
    7) ssh_tunnel ;;
    0) return ;;
    *) echo -e "${RED}  Invalid.${RESET}"; sleep 1; ssh_menu ;;
  esac
}

ssh_connect() {
  echo ""
  if [[ ! -s "$SSH_HOSTS_FILE" ]]; then
    echo -e "  ${WARN} No saved hosts. Add one first."
    pause; ssh_menu; return
  fi

  echo -e "${CYAN}  ── Saved Hosts ─────────────────────────${RESET}\n"
  local i=1
  declare -A hosts
  while IFS='|' read -r alias user host port keyfile; do
    echo -e "  ${GREEN}[$i]${WHITE} $alias${RESET} — ${user}@${host}:${port}"
    hosts[$i]="$user|$host|$port|$keyfile"
    ((i++))
  done < "$SSH_HOSTS_FILE"

  echo ""
  read -rp "  $(echo -e "${CYAN}Select host:${RESET} ")" sel
  IFS='|' read -r user host port keyfile <<< "${hosts[$sel]:-}"

  if [[ -z "$host" ]]; then
    echo -e "${RED}  Invalid selection${RESET}"; pause; ssh_menu; return
  fi

  local ssh_cmd="ssh -p $port $user@$host"
  [[ -n "$keyfile" && -f "$keyfile" ]] && ssh_cmd="ssh -i $keyfile -p $port $user@$host"

  echo -e "\n  ${ARROW} Connecting: $ssh_cmd\n"
  eval "$ssh_cmd"
  pause; ssh_menu
}

ssh_add_host() {
  echo ""
  read -rp "  Alias (e.g. myserver):  " alias
  read -rp "  Username:               " user
  read -rp "  Host/IP:                " host
  read -rp "  Port [22]:              " port
  read -rp "  Key file (or blank):    " keyfile
  port="${port:-22}"
  echo "${alias}|${user}|${host}|${port}|${keyfile}" >> "$SSH_HOSTS_FILE"
  echo -e "\n  ${OK} Host '${alias}' saved."
  pause; ssh_menu
}

ssh_remove_host() {
  echo ""
  local i=1
  declare -A lines
  while IFS='|' read -r alias rest; do
    echo -e "  ${GREEN}[$i]${WHITE} $alias${RESET}"
    lines[$i]="$alias|$rest"
    ((i++))
  done < "$SSH_HOSTS_FILE"

  read -rp "  Remove entry #: " sel
  local alias_to_del
  IFS='|' read -r alias_to_del _ <<< "${lines[$sel]:-}"
  [[ -n "$alias_to_del" ]] && sed -i "/^${alias_to_del}|/d" "$SSH_HOSTS_FILE" && \
    echo -e "  ${OK} Removed '${alias_to_del}'."
  pause; ssh_menu
}

ssh_keygen() {
  echo ""
  read -rp "  Key type [ed25519/rsa]: " ktype
  read -rp "  Key name [id_${ktype:-ed25519}]: " kname
  read -rp "  Comment (e.g. email):   " comment
  ktype="${ktype:-ed25519}"
  kname="${kname:-id_${ktype}}"
  local keypath="$HOME/.ssh/${kname}"
  mkdir -p "$HOME/.ssh"

  if [[ "$ktype" == "rsa" ]]; then
    ssh-keygen -t rsa -b 4096 -C "$comment" -f "$keypath"
  else
    ssh-keygen -t ed25519 -C "$comment" -f "$keypath"
  fi
  echo ""
  echo -e "  ${OK} Keys saved: ${keypath} / ${keypath}.pub"
  echo -e "\n  ${INFO} Your public key:"
  cat "${keypath}.pub" | sed 's/^/  /'
  pause; ssh_menu
}

ssh_copy_key() {
  echo ""
  read -rp "  Public key [~/.ssh/id_ed25519.pub]: " pubkey
  pubkey="${pubkey:-$HOME/.ssh/id_ed25519.pub}"
  read -rp "  Remote user@host:port: " remote
  ssh-copy-id -i "$pubkey" "$remote"
  pause; ssh_menu
}

ssh_start_server() {
  require sshd || {
    echo -e "  ${INFO} Install: pkg install openssh"
    pause; ssh_menu; return
  }
  echo ""
  echo -e "  ${ARROW} Starting SSH server on port 8022..."
  sshd
  echo -e "  ${OK} SSH server running."
  echo -e "  ${INFO} Connect from PC: ssh -p 8022 $(whoami)@<device-ip>"
  echo -e "  ${INFO} Stop with:       pkill sshd"
  pause; ssh_menu
}

ssh_tunnel() {
  echo ""
  echo -e "  ${INFO} Port forward types:"
  echo -e "  [1] Local forward  (access remote service locally)"
  echo -e "  [2] Remote forward (expose local port to remote)"
  echo -e "  [3] Dynamic SOCKS5 proxy"
  read -rp "  $(echo -e "${CYAN}Choice:${RESET} ")" c
  read -rp "  Remote host (user@host): " remote

  case "$c" in
    1)
      read -rp "  Local port:  " lport
      read -rp "  Remote host:port (e.g. 127.0.0.1:80): " raddr
      echo -e "\n  ${ARROW} Tunneling localhost:${lport} → ${remote}:${raddr}"
      ssh -N -L "${lport}:${raddr}" "$remote" &
      echo -e "  ${OK} Tunnel started (PID: $!)"
      ;;
    2)
      read -rp "  Remote port: " rport
      read -rp "  Local host:port (e.g. 127.0.0.1:80): " laddr
      echo -e "\n  ${ARROW} Tunneling ${remote}:${rport} → localhost:${laddr}"
      ssh -N -R "${rport}:${laddr}" "$remote" &
      echo -e "  ${OK} Tunnel started (PID: $!)"
      ;;
    3)
      read -rp "  Local SOCKS port [1080]: " sport
      sport="${sport:-1080}"
      echo -e "\n  ${ARROW} SOCKS5 proxy on port ${sport} via ${remote}"
      ssh -N -D "${sport}" "$remote" &
      echo -e "  ${OK} SOCKS5 proxy started (PID: $!)"
      echo -e "  ${INFO} Configure your browser to use 127.0.0.1:${sport} as SOCKS5"
      ;;
  esac
  pause; ssh_menu
}

ssh_menu
