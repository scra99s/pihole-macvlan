# Pihole on docker macvlan
### WIP
___
The MACVLAN interface is based on the 192.168.1.224/29 portion of a 192.168.0/24 host network subnet:
* __Network__  192.168.1.224
* __MACVLAN__  192.168.1.225
* __Pihole__   192.168.1.226
* __Unused__   192.168.1.227 - 192.168.1.230
* __Broadcast__ 192.168.1.231

There is a chance that you may need to change these ranges depending on your local network configuration.

## __Run__
### __(Docker Engine)__
___

#### __Create Network__
```bash
$ ip link add macvlan0 link eth0 type macvlan mode bridge
$ ip addr add 192.168.1.225 dev macvlan0
$ ip link set macvlan0 up
$ docker network create --driver=macvlan --gateway=192.168.1.1 --subnet=192.168.1.224/29 -o parent=eth0 macvlan0
```
#### __Start Container__
```bash
$ docker run --detach \
  --name pihole \
  --hostname pi.hole
  --publish 53:53/tcp \
  --publish 53:53/udp \
  --publish 80:80/tcp \
  --publish 443:443/tcp \
  --publish 67:67/udp \
  --network "macvlan0" \
  --ip "192.168.1.226" \
  --mac-address "0a:de:ad:ca:fe:a0" \
  --dns=127.0.0.1 \
  --dns=1.1.1.1 \
  --cap-add NET_ADMIN \
  --env VIRTUAL_HOST="pi.hole" \
  --env PROXY_LOCATION="pi.hole" \
  --env ServerIP="192.168.1.226" \
  --env TZ="Australia/Sydney" \
  --volume "/opt/etc-pihole/:/etc/pihole/" \
  --volume "/opt/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
  --restart=unless-stopped \
  pihole/pihole:latest
```
### __(Docker Compose)__
___
#### __Start Container & Create Network__
```bash
docker-compose up -d
```
## __Purge__
### __(Docker Engine)__
___
```bash
docker kill pihole && docker rm pihole
docker network rm macvlan0
```
### __(Docker Compose)__
___
```bash
docker-compose down
```
