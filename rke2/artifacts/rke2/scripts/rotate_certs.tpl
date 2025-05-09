#!/bin/bash

# 허용된 IP 목록 (필요한 만큼 추가)
MASTER_IPS=( \"${master_ip}\" )

# 현재 호스트의 IP 얻기
HOST_IP=\$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# 허용된 IP인지 확인하는 플래그
IS_MASTER=false

# 반복문을 통해 허용된 IP 목록과 비교
for IP in "\${MASTER_IPS[@]}"; do
    if [ "\$HOST_IP" == "\$IP" ]; then
        IS_MASTER=true
        break
    fi
done

# 조건에 따라 동작 수행
if [ "\$IS_MASTER" = true ]; then
    echo \"Master Node 인증서를 갱신합니다.\"
    # stop, rotate, restart rke2 server
    systemctl stop rke2-server
    rke2 certificate rotate
    systemctl start rke2-server
    rke2 certificate check
else
    echo \"Worker Node 인증서를 갱신합니다.\"
    # stop, rotate, restart rke2 agent
    systemctl stop rke2-agent
    rke2 certificate rotate
    systemctl start rke2-agent
    rke2 certificate check
fi
