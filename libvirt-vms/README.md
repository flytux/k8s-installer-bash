### Libvirt 이용 VM 생성

1. libvirt 설치
   - debian : sudo apt install qemu-system libvirt-daemon-system virtinst

3. rocky qcow2 이미지 다운로드 > /var/lib/libvirt/images 폴더로 복사
   - wget https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2

5. node-list 파일에 노드 목록 생성
   - 노드 호스트 이름 m1, w1

3. cloud-init.sh 실행 (ssh-키값 확인)
   - bash cloud-init.sh         # cloud-init-노드명.yaml 생성
   - ssh 접속용 public key 수정  

5. cloud-init/cloud-init-$node.yaml 파일 확인 및 필요 사항 수정
   - vi cloud-init/cloud-init-m1.yaml

7. create-vm.sh, delete-vm.sh 스크립트 실행
   - bash create-vm.sh
   - bash list-ip.sh m1
   - bash delete-vm.sh
     
8. ssh 접속
   - ssh jaehoon@IP

   
