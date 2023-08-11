#!/bin/bash
set -eu

CURRENT_PATH=$(pwd)

# check out repos
git clone https://github.com/nginx/nginx.git
git clone https://github.com/openssl/openssl.git
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
git clone https://github.com/aericpp/nginx-proxy.git

# check nginx version
cd "$CURRENT_PATH/nginx"
NGINX_VERSION=$(test -f .hgtags && cat .hgtags |tail -n 1 |awk '{print $2}')
NGINX_VERSION_NUMBER=$(echo $NGINX_VERSION| cut -c9-)
git checkout $NGINX_VERSION

# check openssl version
cd "$CURRENT_PATH/openssl"
OPENSSL_VERSION=$(git log --simplify-by-decoration --pretty="format:%ct %D" --tags \
    | grep openssl-3.1 \
    | sort -n -k 1 -t " " -r \
    | head -n 1 \
    | awk '{print $3}')
git checkout $OPENSSL_VERSION

# check release
cd "$CURRENT_PATH/nginx-proxy"
git tag -l
TAG_NAME=$(echo "v${NGINX_VERSION_NUMBER}-${OPENSSL_VERSION}")
TAG_EXIST=$(git tag -l ${TAG_NAME})

echo "$TAG_NAME" > $CURRENT_PATH/release.version
echo "1" > $CURRENT_PATH/tmp.flag
if [ "$TAG_NAME" == "$TAG_EXIST" ]; then
    echo "0" > $CURRENT_PATH/tmp.flag
    # exit 0
fi

# compile nginx-proxy
cd "$CURRENT_PATH/nginx"
git checkout $NGINX_VERSION

# patch for http connect method
mv auto/configure configure
patch -p1 <../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

./configure \
    --with-cc-opt='-static -static-libgcc' \
    --with-ld-opt=-static \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --modules-path=/usr/lib/nginx/modules \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --without-mail_pop3_module \
    --without-mail_imap_module \
    --without-mail_smtp_module \
    --without-http_memcached_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --with-http_gzip_static_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_v2_module \
    --with-openssl="${CURRENT_PATH}/openssl" \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --add-module="${CURRENT_PATH}/ngx_http_proxy_connect_module"

make

# get execute file
test -d ${CURRENT_PATH}/nginx_debian/usr/sbin/ || mkdir -p ${CURRENT_PATH}/nginx_debian/usr/sbin/
cp ${CURRENT_PATH}/nginx/objs/nginx ${CURRENT_PATH}/nginx_debian/usr/sbin/nginx

# make deb package
cd ${CURRENT_PATH}
NG_PKG_SIZE=`du -sk nginx_debian|awk '{print $1}'`
# NG_PKG_VERSION=${NGINX_VERSION_NUMBER}
test -d "nginx_debian/DEBIAN" || mkdir -p "nginx_debian/DEBIAN" 
sed -e "s|%%SIZE%%|${NG_PKG_SIZE}|" -e "s|%%VERSION%%|${NGINX_VERSION_NUMBER}|" < control_tmpl > nginx_debian/DEBIAN/control
test -d "nginx_debian/var/lib/nginx" || mkdir -p "nginx_debian/var/lib/nginx"        
test -d "nginx_debian/var/log/nginx" || mkdir -p "nginx_debian/var/log/nginx"
test -d "nginx_debian/var/www/html" || mkdir -p "nginx_debian/var/www/html"
test -d "nginx_debian/etc/nginx/modules-available" || mkdir -p "nginx_debian/etc/nginx/modules-available"
test -d "nginx_debian/etc/nginx/modules-enabled" || mkdir -p "nginx_debian/etc/nginx/modules-enabled"
test -d "nginx_debian/etc/nginx/conf.d" || mkdir -p "nginx_debian/etc/nginx/conf.d"
test -d "nginx_debian/etc/nginx/sites-enabled" || mkdir -p "nginx_debian/etc/nginx/sites-enabled"
dpkg -b nginx_debian nginx_proxy.deb
tar cvzf nginx_proxy_deb_src.tar.gz nginx_debian