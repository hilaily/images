#!/bin/bash
# gen_cert.sh sub.a.com

# set your dns token and dns provider
# https://github.com/acmesh-official/acme.sh/wiki/dnsapi
#
# for exapmle
# export CF_Token=''
# export CF_Account_ID=''
# DNS_PROVIDER=dns_cf

domain=$1

~/.acme.sh/acme.sh --issue --dns $DNS_PROVIDER -d $domain

path="/opt/app/nginx/sslcert/$domain" # 提前创建好这个目录，并且把权限给给到当前用户，不是给到 root。
sudo mkdir -p /opt/app/nginx/sslcert
sudo chown $USER /opt/app/nginx/sslcert

mkdir -p $path

$HOME/.acme.sh/acme.sh --install-cert -d $domain \
    --key-file $path/$domain.key \
    --fullchain-file $path/fullchain.cer \
    --reloadcmd "docker exec nginx nginx -s reload"
