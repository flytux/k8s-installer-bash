### K8S installer with BASH

```
# Kubeadm / RKE2 기반 Bash 설치 스크립트
# 리눅스 VM에 SSH 연결 설정 후 node-list.yaml 설정 후 실행 (yq 설치 필요)

# 제공 기능
- 클러스터 생성, 노드 추가, 업그레이드, 클러스터 삭제
- 설치 버전, 업그레이드 버전 지정
- 멀티 마스터, 멀티 워커 노드 구성
- Cilium CNI
- Traefik ingress controller 설치
```
#### 설치 순서
- libvirt vm 스크립트를 이용한 vm 생성 (키파일 확인)

- kubeadm 스크립트의 node-list.yaml 확인
  - 노드 정보, ssh 키, kubernetes 버전 등
  - bash create-cluster.sh 로 클러스터 생성
 
- rke2 스크립트의 node-list.yaml 확인
  - 노드 정보, ssh 키, kubernetes 버전 등
  - bash create-cluster.sh 로 클러스터 생성

- Install Kubeadm 2 node cluster
<a href="https://asciinema.org/a/07UJgPgGwkKdEtgRNxkU4JKY4" target="_blank"><img src="https://asciinema.org/a/07UJgPgGwkKdEtgRNxkU4JKY4.svg" width="1024" /></a>
