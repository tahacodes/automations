#!/bin/bash

A_RECORD=$1
DOMAIN=$2

if [ -z "$1" ] || [ -z "$2" ]
then
      echo -e "\nuse program like this:\n\n\tsudo ./script <a_record_address> <domain>\n"
      exit
fi

DNSSERVER_IP=$(curl -4 icanhazip.com)
BIND_CONFIG_PREFIX='/etc/bind'

apt update && apt upgrade -y
apt install -y bind9 bind9-doc

echo """
options {
    directory \"/var/cache/bind\";
    allow-query { any; };
    listen-on { any; };

    forwarders {
            8.8.8.8;
            8.8.4.4;
    };

    dnssec-validation auto;
    auth-nxdomain no;
};
""" > $BIND_CONFIG_PREFIX/named.conf.options

mkdir /etc/bind/zones
echo """
zone \"$DOMAIN\" {
    type master;
    file \"$BIND_CONFIG_PREFIX/zones/db.$DOMAIN\";
};
""" > $BIND_CONFIG_PREFIX/named.conf.local

echo """
\$TTL    604800
@       IN      SOA     ns1.$DOMAIN. email.$DOMAIN. (
                              3         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
; list nameservers
                 IN      NS      ns1.$DOMAIN.
                 IN      NS      ns2.$DOMAIN.

; address to name mapping
$DOMAIN.           IN      A       $A_RECORD
www.$DOMAIN.       IN      A       $A_RECORD
ns1.$DOMAIN.       IN      A       $DNSSERVER_IP
ns2.$DOMAIN.       IN      A       $DNSSERVER_IP
""" > $BIND_CONFIG_PREFIX/zones/db.$DOMAIN

systemctl restart systemd-resolved.service
systemctl restart bind9

echo "DONE."
