#!/bin/bash

sudo apt update
sudo apt install -y nginx easy-rsa openssl

mkdir /home/ubuntu/easy-rsa
ln -s /usr/share/easy-rsa/* /home/ubuntu/easy-rsa/
chmod 700 /home/ubuntu/easy-rsa/
cd /home/ubuntu/easy-rsa
./easyrsa init-pki

echo """
set_var EASYRSA_REQ_COUNTRY    \"US\"
set_var EASYRSA_REQ_PROVINCE   \"New York\"
set_var EASYRSA_REQ_CITY       \"New York City\"
set_var EASYRSA_REQ_ORG        \"tahacodes\"
set_var EASYRSA_REQ_CN         \"www.webserver.local\"
set_var EASYRSA_REQ_EMAIL      \"admin@webserver.local\"
set_var EASYRSA_REQ_OU         \"Community\"
set_var EASYRSA_ALGO           \"ec\"
set_var EASYRSA_DIGEST         \"sha512\"
set_var EASYRSA_BATCH          \"yes\"
""" > /home/ubuntu/easy-rsa/vars

./easyrsa build-ca nopass
mkdir /home/ubuntu/practice-csr
cd /home/ubuntu/practice-csr
openssl genrsa -out webserver.key
openssl req -new -key webserver.key -out webserver.req -subj \
/C=US/ST=New\ York/L=New\ York\ City/O=tahacodes/OU=IT/CN=www.webserver.local/emailAddress=admin@webserver.local

cd /home/ubuntu/easy-rsa
./easyrsa import-req ../practice-csr/webserver.req webserver
./easyrsa sign-req server webserver

mkdir /etc/ssl/webserver
cp /home/ubuntu/easy-rsa/pki/issued/webserver.crt /etc/ssl/webserver/
cp /home/ubuntu/practice-csr/webserver.key /etc/ssl/webserver/

echo """
server {
        listen 80;
        listen [::]:80;
        server_name _;
        return 301 https://\$host\$request_uri;
}

server {
        listen 443 ssl;
        listen [::]:443 ssl;

        ssl_certificate /etc/ssl/webserver/webserver.crt;
        ssl_certificate_key /etc/ssl/webserver/webserver.key;

        server_name _;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        location / {
                try_files $uri $uri/ =404;
        }
}
""" > /etc/nginx/sites-available/default

nginx -t
systemctl restart nginx

echo "DONE."