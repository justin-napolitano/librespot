---
slug: github-librespot-note-technical-overview
id: github-librespot-note-technical-overview
title: librespot Overview
repo: justin-napolitano/librespot
githubUrl: https://github.com/justin-napolitano/librespot
generatedAt: '2025-11-24T18:40:26.242Z'
source: github-auto
summary: >-
  librespot is a lightweight Spotify Connect client for Ubuntu, turning your
  system into a Spotify speaker using ALSA. It’s great for headless operations
  with OAuth authentication over SSH, making it fit for servers or embedded
  setups without a UI.
tags: []
seoPrimaryKeyword: ''
seoSecondaryKeywords: []
seoOptimized: false
topicFamily: null
topicFamilyConfidence: null
kind: note
entryLayout: note
showInProjects: false
showInNotes: true
showInWriting: false
showInLogs: false
---

librespot is a lightweight Spotify Connect client for Ubuntu, turning your system into a Spotify speaker using ALSA. It’s great for headless operations with OAuth authentication over SSH, making it fit for servers or embedded setups without a UI.

## Key Features

- Uses the ALSA backend for audio playback.
- Runs securely as a dedicated user (`spotify`).
- Advertises via mDNS for device discovery.
- Stores credentials safely under `/var/lib/librespot`.
- Supports headless OAuth authentication through SSH tunneling.
- Integrated with systemd for service management.

## Quick Start

### Installation

Run the installer script:

```bash
curl -fsSL https://example.com/librespot_alsa_install.sh -o /tmp/librespot_alsa_install.sh
sudo bash /tmp/librespot_alsa_install.sh
```

### Start librespot

Launch with:

```bash
sudo -u spotify /usr/local/bin/librespot -n "Apartment Jam" -B alsa -d plughw:0,0
```

Then create an SSH tunnel:

```bash
ssh -L 8888:127.0.0.1:8888 user@SERVER_LAN_IP
```

Complete OAuth in your browser, then restart:

```bash
sudo systemctl restart librespot
```

## Gotchas

- Ensure AP client isolation is off. UDP port 5353 must be open for mDNS.
