[ -f rke2-images.linux-amd64.tar.zst ] || curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/rke2-images.linux-amd64.tar.zst
[ -f rke2.linux-amd64.tar.gz ] || curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/rke2.linux-amd64.tar.gz
[ -f sha256sum-amd64.txt ] || curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/sha256sum-amd64.txt
[ -f install.sh ] || curl -sfL https://get.rke2.io --output install.sh