helm repo add cilium https://helm.cilium.io/ --force-update
helm fetch cilium/cilium

helm repo add traefik https://helm.traefik.io/traefik --force-update
helm fetch traefik/traefik 
