#!/bin/sh

# Download rke2 upgrade binary
curl -LO https://github.com/rancher/rke2/releases/download/${upgrade_rke2_version}%2Brke2r1/rke2.linux-amd64

# Stop rke2-server service
systemctl stop rke2-server.service

# Copy new rke2 binary
cp /usr/local/bin/rke2 /usr/local/bin/rke2-${rke2_version}
mv rke2.linux-amd64 /usr/local/bin/rke2
chmod +x /usr/local/bin/rke2

# Restart rke2 service
systemctl restart rke2-server.service

