---
slug: github-librespot
id: github-librespot
title: 'Setting Up Librespot: A Lightweight Spotify Connect Client'
repo: justin-napolitano/librespot
githubUrl: https://github.com/justin-napolitano/librespot
generatedAt: '2025-11-24T21:35:26.868Z'
source: github-auto
summary: >-
  Learn how to install and configure Librespot on Ubuntu for headless Spotify Connect functionality
  using ALSA audio backend.
tags:
  - librespot
  - spotify connect
  - alsa
  - systemd
  - mdns
  - rust
  - oauth
seoPrimaryKeyword: librespot installation guide
seoSecondaryKeywords:
  - spotify connect client
  - ubuntu audio setup
  - headless operation
  - oauth authentication
  - systemd service management
seoOptimized: true
topicFamily: devtools
topicFamilyConfidence: 0.9
kind: project
entryLayout: project
showInProjects: true
showInNotes: false
showInWriting: false
showInLogs: false
---

librespot is a lightweight Spotify Connect client designed to turn an Ubuntu system into a Spotify Connect speaker using the ALSA audio backend. It enables headless operation with OAuth authentication via SSH tunneling, making it suitable for embedded or server environments without graphical interfaces.

## Features

- Builds librespot with ALSA backend and libmdns for audio playback and network discovery
- Runs as a dedicated system user (`spotify`) for security and isolation
- Advertises device over mDNS for Spotify Connect discovery
- Supports headless OAuth authentication via SSH tunnel
- Persists credentials securely under `/var/lib/librespot`
- Configured for ALSA-only audio output pinned to `plughw:0,0`
- Provides systemd integration for service management

## Tech Stack

- Shell scripting for installation and setup
- librespot (Rust-based Spotify Connect client)
- ALSA (Advanced Linux Sound Architecture) for audio output
- mDNS (via libmdns) for network service advertisement
- Systemd for service management

## Getting Started

### Installation

Download and run the installer script:

```bash
curl -fsSL https://example.com/librespot_alsa_install.sh -o /tmp/librespot_alsa_install.sh
sudo bash /tmp/librespot_alsa_install.sh
```

### One-time OAuth Authentication (Headless)

On the server, start librespot with the following command:

```bash
sudo -u spotify /usr/local/bin/librespot \
  -n "Apartment Jam" -B alsa -d plughw:0,0 -b 160 -R 75 -E log \
  -i $(hostname -I | awk '{print $1}') -z 8765 -C /var/lib/librespot -K 8888 -j
```

Leave this running. From your laptop, create an SSH tunnel to the server:

```bash
ssh -L 8888:127.0.0.1:8888 cobra@SERVER_LAN_IP
```

Open the Spotify URL printed by librespot in your browser, complete the login, and wait for "Logged in" confirmation.

Then restart the librespot service:

```bash
sudo systemctl restart librespot
```

### Usage

Connect to the same Wi-Fi network and select the device named **Apartment Jam** from your Spotify client device list.

### Quick Operations

Monitor logs and manage the service:

```bash
journalctl -u librespot -f
sudo systemctl restart librespot
avahi-browse -rt _spotify-connect._tcp | grep "Apartment Jam"
```

## Project Structure

- `index.md`: Documentation and usage guide
- `install.sh`: Installer script for setting up librespot with ALSA backend

## Future Work / Roadmap

- Add support for PipeWire backend to expand compatibility
- Enhance installation script with more robust error handling and configuration options
- Automate OAuth token refresh and renewal process
- Provide Docker container support for easier deployment
- Extend device discovery and configuration options


---

# Notes

- Ensure AP client isolation is disabled and UDP port 5353 is allowed for mDNS discovery
- To update librespot:

```bash
cargo install librespot --locked --no-default-features --features "alsa-backend native-tls with-libmdns"
sudo install -m0755 ~/.cargo/bin/librespot /usr/local/bin/librespot
sudo systemctl restart librespot
```


