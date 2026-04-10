### Cilium Traffic Split Test

```

GATEWAY=$(kubectl get gateway cilium-gw -o jsonpath='{.status.addresses[0].value}')
curl --fail -s http://$GATEWAY/echo

while true; do curl -s -k "http://$GATEWAY/echo" >> curlresponses.txt ;done

cat curlresponses.txt| grep -c "Hostname: echo-1"
cat curlresponses.txt| grep -c "Hostname: echo-2"


```

