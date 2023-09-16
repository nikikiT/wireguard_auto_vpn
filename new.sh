#!/bin/bash
var2="$2"
var1="$1"
var3="$3"
a="var1"
external_ip=$(curl -s https://ipinfo.io/ip)
cd /etc/wireguard/
mkdir "${!a}"
cd "${!a}"
wg genkey | tee /etc/wireguard/"${!a}"/private_serv_key_"${!a}" | wg pubkey | tee /etc/wireguard/"${!a}"/public_serv_key_"${!a}"
pubkey_serv=$(cat public_serv_key_"${!a}")
privatekey_serv=$(cat private_serv_key_"${!a}")

wg genkey | tee /etc/wireguard/"${!a}"/privatekey_"${!a}" | wg pubkey | tee /etc/wireguard/"${!a}"/publickey_"${!a}"
pubkey=$(cat publickey_"${!a}")
privatekey=$(cat privatekey_"${!a}")

touch wg_"${!a}".conf

echo "[Interface]
PrivateKey =${privatekey_serv} 
Address = ${external_ip}
ListenPort =518${var2} 
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE 
[Peer]
PublicKey =${pubkey} 
AllowedIPs =10.0.0.${var3} "  > wg_"${!a}".conf

touch client_"${!a}".conf

echo "[Interface]
PrivateKey = ${privatekey}
Address = 10.0.0.${var3}
DNS = 8.8.8.8

[Peer]
PublicKey = ${pubkey_serv}
Endpoint = ${external_ip}:518${var2}
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20 "  > client_"${!a}".conf

serv_name_conf=wg_"${!a}".conf
client_name_conf=client_"${!a}".conf

cp $serv_name_conf  ../
cd ..
systemctl enable wg-quick@wg_"${!a}".service
systemctl start wg-quick@wg_"${!a}".service
systemctl status wg-quick@wg_"${!a}".service
rm $serv_name_conf

cd ${!a}
cat $client_name_conf
