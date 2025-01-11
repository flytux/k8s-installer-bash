#!/bin/bash

echo "==== kubeadm reset ===="
kubeadm reset --force

echo "==== clean cni plugins, iptables ===="
rm -rf kubeadm && rm -rf /etc/cni/net.d