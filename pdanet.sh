#!/bin/bash

WORKSPACE=$(dirname "$(realpath "$0")")
SCRIPT_NAME=$(basename "$0")

logo() {
echo "
 ___         _             _                       _
|_  |  ___ _| |___ _ _ ___| |___ ___ _____ ___ ___| |_
 _| |_|   | . | -_| | | -_| | . | . |     | -_|   |  _|
|_____|_|_|___|___|\_/|___|_|___|  _|_|_|_|___|_|_| |
  pdanet wifi tether installer  |_|   Linux v0.1  |__|"
}

rootcheck() { [[ "$(id -u)" -ne 0 ]] && { echo -e "\n* run as superuser."; exit 1; } ; }

set_proxy() {
  if [ -n "$http_proxy" ]; then
    echo "* Proxy is set via $http_proxy (wlan0)"
  else
    export http_proxy="http://192.168.49.1:8000" https_proxy="$http_proxy" ftp_proxy="$http_proxy" no_proxy="localhost,127.0.0.1,.localhost"
    # set http proxy for git
    git config --global http.proxy $http_proxy ; git config --global https.proxy $http_proxy
    # set http proxy for wget
    sed -i -e '85s/.*/http-proxy=http:\/\/192\.168\.49\.1:8000/' -e '86s/.*/https-proxy=http:\/\/192\.168\.49\.1:8000/' -e '87s/.*/ftp-proxy=http:\/\/192\.168\.49\.1:8000/' -e '90s/.*/use_proxy=on/' /etc/wgetrc
    set_proxy
  fi
}

set_pkgman_proxy() {
if command -v apt > /dev/null 2>&1; then
  # set http proxy for apt and apt-get
  rm /etc/apt/apt.conf.d/proxy.conf
  touch /etc/apt/apt.conf.d/proxy.conf
  echo 'Acquire{HTTP::proxy "http://192.168.49.1:8000";HTTPS::proxy "http://192.168.49.1:8000";}' > /etc/apt/apt.conf.d/proxy.conf
  echo "* Apt is now using the proxy"
elif command -v pacman > /dev/null 2>&1; then
  echo "* Pacman is now using the proxy"
else
  echo "* Package manager not detected."
fi
}

exec_tunnel() {
  # Tunnel interface setup
  ip tuntap add mode tun dev tun0 > /dev/null 2>&1
  ip addr add 192.168.1.1/24 dev tun0 > /dev/null 2>&1
  ip link set dev tun0 up > /dev/null 2>&1
  ip route del default > /dev/null 2>&1
  ip route add default via 192.168.1.1 dev tun0 metric 1 > /dev/null 2>&1
  ip route add default via 192.168.49.1 dev wlan0 metric 10 > /dev/null 2>&1
  # Disable rp_filter to receive packets from other interfaces
  sysctl -w net.ipv4.conf.all.rp_filter=0 > /dev/null 2>&1
  # Create a configuration file for HevSocks5Tunnel
cat << EOF > $WORKSPACE/config.yml
tunnel:
  name: tun0
  mtu: 8500
  ipv4: 192.168.1.1
socks5:
  address: 192.168.49.1
  port: 8000
  udp: tcp
misc:
  log-level: info
EOF
  echo -e "* Socks5 tunnel initiated via 192.168.1.1 (tun0)\n\n- press any key to start socks5 connection -\n"
  read input
  # Run HevSocks5Tunnel
  ./hev-socks5-tunnel-linux-$ARCH config.yml
}

cleanup() {
  echo -e "\ncleaning up..."
  # unset proxy variables
  unset {http,https,ftp,no}_proxy
  # unset proxy for git
  git config --global --unset http.proxy ; git config --global --unset https.proxy
  # unset proxy for wget
  sed -i -e '85s/.*/#http-proxy=http:\/\/192\.168\.49\.1:8000/' \
         -e '86s/.*/#https-proxy=http:\/\/192\.168\.49\.1:8000/' \
         -e '87s/.*/#ftp-proxy=http:\/\/192\.168\.49\.1:8000/' \
         -e '90s/.*/#use_proxy=on/' /etc/wgetrc
  kill -9 $(sudo pgrep -f hev-socks5-tunnel-linux-x86_64) > /dev/null 2>&1
  rm -fr config.yml
}

init() {
  if [ -f "./hev-socks5-tunnel-linux-$ARCH" ]; then
    echo -e "* Hev Socks5 Tunnel binary found\n"
    set_proxy ; set_pkgman_proxy ; exec_tunnel
  else
    URL="https://github.com/heiher/hev-socks5-tunnel/releases/download/2.7.5/hev-socks5-tunnel-linux-$ARCH"
    echo -e "! Hev Socks5 Tunnel binary not found !\n\nFetching latest version...\n"
    wget -q --show-progress -e use_proxy=yes -e https_proxy=http://192.168.49.1:8000 -P $WORKSPACE/ $URL ; echo ""
    chmod +x ./hev-socks5-tunnel-linux-$ARCH ; detect_arch
  fi
}

detect_arch() {
  logo ; rootcheck
  ARCH="$(uname -m)"
  case "$ARCH" in
    x86_64) echo -e "\n* 64-bit architecture detected"; init;;
    i686|i386) echo -e "\n* 32-bit architecture detected"; init;;
    arm64|aarch64) echo -e "\n* Arm64 architecture detected"; init;;
    *) echo -e "\nUnknown architecture: $ARCH"; exit 1;;
  esac
  cleanup
}
detect_arch
exit 0
