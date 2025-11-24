---
slug: github-librespot
title: 'librespot: Headless Spotify Connect on Ubuntu with ALSA Audio'
repo: justin-napolitano/librespot
githubUrl: https://github.com/justin-napolitano/librespot
generatedAt: '2025-11-23T09:13:33.405042Z'
source: github-auto
summary: >-
  Technical overview and setup notes for running librespot as a headless Spotify Connect client on
  Ubuntu using ALSA and SSH-tunneled OAuth authentication.
tags:
  - spotify-connect
  - librespot
  - ubuntu
  - alsa
  - headless
  - oauth
seoPrimaryKeyword: librespot
seoSecondaryKeywords:
  - spotify connect
  - alsa audio
  - headless ubuntu
  - oauth authentication
seoOptimized: true
topicFamily: devtools
topicFamilyConfidence: 0.95
topicFamilyNotes: >-
  The post details setup, configuration, and deployment of librespot on Ubuntu including system user
  creation, systemd service setup, audio hardware configuration, and headless OAuth authentication.
  These are all strongly aligned with development environment and system tooling, matching well with
  the 'devtools' family that includes linux, shell, and reproducible workstation setups. Other
  families like automation or datascience do not fit as well since the focus is not primarily on
  scripting pipelines or data workflows.
---

# librespot: Technical Reference and Implementation Notes

## Motivation and Problem Statement

The objective is to transform an Ubuntu machine into a Spotify Connect endpoint that operates headlessly and uses the ALSA audio backend exclusively. This setup addresses scenarios where lightweight, non-GUI Spotify playback is required, such as embedded systems, headless servers, or minimal Linux setups without PipeWire.

Spotify Connect allows devices to appear as playback targets in the Spotify ecosystem. librespot is an open-source client implementation enabling this functionality without official Spotify hardware.

## How It Works

The project builds librespot with specific features:

- **ALSA backend**: Ensures audio output is routed through ALSA, bypassing other audio servers like PulseAudio or PipeWire.
- **libmdns**: Provides mDNS service advertisement, allowing the device to be discoverable on the local network as a Spotify Connect target.

librespot runs as a dedicated system user (`spotify`) for security and process isolation. Audio output is pinned to the hardware device `plughw:0,0` using ALSA device naming conventions.

## Headless OAuth Authentication

Spotify Connect requires OAuth authentication. Since the target device is headless, the authentication flow is facilitated via an SSH tunnel:

1. librespot is launched on the server with flags to enable OAuth and bind to specific IP and ports.
2. The user establishes an SSH tunnel forwarding the OAuth callback port from the server to their local machine.
3. The Spotify login URL is accessed locally, completing the OAuth flow.
4. Upon successful login, librespot receives and stores credentials persistently in `/var/lib/librespot`.

This approach avoids the need for a graphical interface on the server.

## Installation and Deployment

An installation script (`install.sh`) automates building librespot with the required features and setting up systemd service files. The script:

- Downloads and compiles librespot with ALSA and libmdns support
- Creates the `spotify` system user
- Sets up directories for persistent credentials
- Configures systemd service for automatic startup and management

## Operational Details

- The device advertises itself over mDNS using the `_spotify-connect._tcp` service type.
- Firewall rules must allow UDP port 5353 for mDNS and relevant TCP ports for OAuth and streaming.
- The systemd service can be monitored via `journalctl` and controlled with `systemctl`.

## Technical Considerations

- ALSA device selection is critical; `plughw:0,0` is hardcoded but may require adjustment depending on hardware.
- mDNS discovery depends on network configuration; client isolation on Wi-Fi access points must be disabled.
- OAuth token persistence ensures that reboots or service restarts do not require repeated authentication.

## Updating librespot

The recommended update procedure involves recompiling librespot with the same feature flags and replacing the binary in `/usr/local/bin`. This maintains consistency with the ALSA backend and mDNS support.

## Future Directions

- Incorporate support for PipeWire to broaden compatibility with modern Linux audio stacks.
- Improve automation of OAuth token refresh to minimize manual intervention.
- Containerize the application for easier deployment and isolation.
- Enhance logging and error handling for production readiness.

## Summary

This project provides a practical, minimalistic solution to enable Spotify Connect on headless Ubuntu systems using ALSA. It balances security, usability, and network integration through careful configuration and scripting. The SSH tunnel OAuth flow is a pragmatic solution to headless authentication challenges. The current implementation is best suited for users comfortable with Linux system administration and command-line tooling.

