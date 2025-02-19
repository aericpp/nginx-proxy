#!/bin/bash
set -eu

CURRENT_PATH=$(pwd)
echo "[debug] CURRENT_PATH: $CURRENT_PATH"
git clone https://github.com/nginx/nginx.git
git clone https://github.com/openssl/openssl.git
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
git clone https://github.com/aericpp/nginx-proxy.git

# check nginx version
cd "$CURRENT_PATH/nginx"
NGINX_VERSION=$(git log --simplify-by-decoration --pretty="format:%ct %D" --tags \
    | sort -k 1 -t ":" -r \
    | head -n 5 \
    | sort -k 2 -t ":" -r \
    | head -n 1 \
    | awk '{print $3}') 
# NGINX_VERSION=$(test -f .hgtags && cat .hgtags |tail -n 1 |awk '{print $2}')
echo "[debug] NGINX_VERSION: $NGINX_VERSION"
echo $NGINX_VERSION > "$CURRENT_PATH/nginx.version"
NGINX_VERSION_NUMBER=$(echo $NGINX_VERSION| cut -c9-)
echo "[debug] NGINX_VERSION_NUMBER: $NGINX_VERSION_NUMBER"
echo $NGINX_VERSION_NUMBER > "$CURRENT_PATH/nginx.version.number"
git checkout $NGINX_VERSION

# check openssl version
cd "$CURRENT_PATH/openssl"
OPENSSL_VERSION=$(git log --simplify-by-decoration --pretty="format:%ct %D" --tags \
    | grep openssl-3. \
    | grep -v alpha \
    | grep -v beta \
    | sort -k 2 -t ":" -r \
    | head -n 1 \
    | awk '{print $3}')
echo "[debug] OPENSSL_VERSION: $OPENSSL_VERSION"
git checkout $OPENSSL_VERSION
echo $OPENSSL_VERSION > "$CURRENT_PATH/openssl.version"

# check release
cd "$CURRENT_PATH/nginx-proxy"
TAG_NAME=$(echo "v${NGINX_VERSION_NUMBER}-${OPENSSL_VERSION}")
echo "[debug] TAG_NAME: $TAG_NAME"
TAG_EXIST=$(git tag -l ${TAG_NAME})
echo "[debug] TAG_EXIST: $TAG_EXIST"

echo $TAG_NAME > "$CURRENT_PATH/release.version"
echo $TAG_EXIST > "$CURRENT_PATH/tag.exist"

if [ "$TAG_NAME" == "$TAG_EXIST" ]; then
  echo 0
else
  echo 1
fi