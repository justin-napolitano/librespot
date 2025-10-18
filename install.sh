
# Installer script (`librespot_alsa_install.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

NAME="Apartment Jam"
USER_SVC="spotify"
CACHE_DIR="/var/lib/librespot"
DEVICE="plughw:0,0"
BITRATE="160"
INIT_VOL="75"
VOL_CTRL="log"
PORT="8765"
LAN_IP="$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}')"

echo "[*] Packages"
sudo apt update
sudo apt install -y alsa-utils avahi-daemon ufw build-essential pkg-config libasound2-dev curl

echo "[*] Service user"
if ! id -u "$USER_SVC" >/dev/null 2>&1; then
  sudo useradd -r -m -s /usr/sbin/nologin "$USER_SVC"
fi
sudo usermod -aG audio "$USER_SVC"

echo "[*] Rust toolchain"
if ! command -v cargo >/dev/null 2>&1; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
fi

echo "[*] Build librespot with ALSA + libmdns"
cargo install librespot --locked --no-default-features --features "alsa-backend native-tls with-libmdns"
sudo install -m0755 "$HOME/.cargo/bin/librespot" /usr/local/bin/librespot

echo "[*] Persist cache dir"
sudo mkdir -p "$CACHE_DIR"
sudo chown -R "$USER_SVC:audio" "$CACHE_DIR"

echo "[*] Minimal ALSA default passthrough (optional override of PipeWire stubs)"
sudo bash -c 'cat >/etc/asound.conf' <<'EOF'
pcm.!default {
  type plug
  slave.pcm "plughw:0,0"
}
ctl.!default {
  type hw
  card 0
}
EOF

echo "[*] Systemd unit"
sudo bash -c "cat >/etc/systemd/system/librespot.service" <<EOF
[Unit]
Description=Spotify Connect (librespot, ALSA)
After=network-online.target sound.target avahi-daemon.service
Wants=network-online.target avahi-daemon.service

[Service]
User=$USER_SVC
Group=audio
WorkingDirectory=$CACHE_DIR
ExecStart=/usr/local/bin/librespot -n "$NAME" -B alsa -d $DEVICE -b $BITRATE -R $INIT_VOL -E $VOL_CTRL -i $LAN_IP -z $PORT -C $CACHE_DIR
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Firewall and mDNS"
sudo ufw allow 5353/udp || true
sudo ufw allow ${PORT}/tcp || true
sudo systemctl enable --now avahi-daemon

echo "[*] Enable service"
sudo systemctl daemon-reload
sudo systemctl enable --now librespot

echo
echo "[OK] librespot running. Next steps:"
echo "1) One-time OAuth (headless) to bind your account:"
echo "   sudo -u $USER_SVC /usr/local/bin/librespot -n \"$NAME\" -B alsa -d $DEVICE -b $BITRATE -R $INIT_VOL -E $VOL_CTRL -i $LAN_IP -z $PORT -C $CACHE_DIR -K 8888 -j"
echo "   From your laptop:  ssh -L 8888:127.0.0.1:8888 cobra@${LAN_IP}"
echo "   Open the printed URL, finish login, wait for 'Logged in', Ctrl-C."
echo "2) Restart service:   sudo systemctl restart librespot"
echo "3) On phone: Spotify → device icon → \"$NAME\"."
