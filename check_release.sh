#!/bin/bash
set -eu

CURRENT_PATH=$(pwd)

git clone https://github.com/nginx/nginx.git
git clone https://github.com/openssl/openssl.git
# git clone https://github.com/aericpp/nginx-proxy.git
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git


# check nginx version
cd "$CURRENT_PATH/nginx"
NGINX_VERSION=$(test -f .hgtags && cat .hgtags |tail -n 1 |awk '{print $2}')
NGINX_VERSION_NUMBER=$(echo $NGINX_VERSION| cut -c9-)
git checkout $NGINX_VERSION


cd "$CURRENT_PATH/openssl"
OPENSSL_VERSION=$(git log --simplify-by-decoration --pretty="format:%ct %D" --tags \
    | grep openssl-3.1 \
    | sort -n -k 1 -t " " -r \
    | head -n 1 \
    | awk '{print $3}')
git checkout $OPENSSL_VERSION

# check release
cd "$CURRENT_PATH"
TAG_NAME=$(echo "v${NGINX_VERSION_NUMBER}-${OPENSSL_VERSION}")
TAG_EXIST=$(git tag -l ${TAG_NAME})

echo $TAG_NAME > "$CURRENT_PATH/release.version"

if [ "$TAG_NAME" == "$TAG_EXIST" ]; then
  echo 0
else
  echo 1
fi