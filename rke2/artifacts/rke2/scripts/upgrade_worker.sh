#!/bin/sh

# Download rke2 upgrade binary
curl -LO https://github.com/rancher/rke2/releases/download/v1.32.0%2Brke2r1/rke2.linux-amd64

# Stop rke2-agent service
systemctl stop rke2-agent.service

# Copy new rke2 binary
cp /usr/local/bin/rke2 /usr/local/bin/rke2-v1.31.0
mv rke2.linux-amd64 /usr/local/bin/rke2
chmod +x /usr/local/bin/rke2

# Restart rke2-agent service
systemctl restart rke2-agent.service
