#!/usr/bin/env bash
## Bash script is WIP DON'T USE

piholeHome="/opt"

hostNetInterface="eth0"
hostNetSubnet="192.168.1.0/24"
hostNetGateway="192.168.1.1"

bridgeNetName="pihole-macvlan0"
bridgeNetSubnet="192.168.1.224/29"
bridgeNetAddress="192.168.1.225"
bridgeNetPiholeAddress="192.168.1.226"
bridgeNetPiholeMac="0a:de:ad:ca:fe:a0"

function host_network_up() {
  ip link add "${bridgeNetName}" link "${hostNetInterface}" type macvlan mode bridge
  ip addr add "${bridgeNetAddress}" dev "${bridgeNetName}"
  ip link set "${bridgeNetName}" up
  #docker network create --driver=macvlan --gateway="${hostNetGateway}" --subnet="${bridgeNetSubnet}" -o parent="${hostNetInterface}" "${bridgeNetName}"
}

function host_network_down() {
  ip link set "${bridgeNetName}" down
  ip link delete "${bridgeNetName}"
  #docker network rm ${bridgeNetName}
}

function run_image() {

  docker run --detach \
    --name pihole \
    --hostname pi.hole
    --publish 53:53/tcp \
    --publish 53:53/udp \
    --publish 80:80/tcp \
    --publish 443:443/tcp \
    --publish 67:67/udp \
    --network "${bridgeNetName}"
    --ip "${bridgeNetPiholeAddress}" \
    --mac-address "0a:de:ad:ca:fe:a0" \
    --dns=127.0.0.1 \
    --dns=1.1.1.1 \
    --cap-add NET_ADMIN \
    --env VIRTUAL_HOST="pi.hole" \
    --env PROXY_LOCATION="pi.hole" \
    --env ServerIP="127.0.0.1" \
    --env TZ="Australia/Sydney" \
    --volume "${piholeHome}/etc-pihole/:/etc/pihole/" \
    --volume "${piholeHome}/etc-dnsmasq.d/:/etc/dnsmasq.d/" \
    --restart=unless-stopped \
    pihole/pihole:latest
}

[[ "$1" == "up" ]] && network_up || network_down