#!/bin/sh
set -eu

apt update
apt install -qy build-essential libpcre3-dev zlib1g-dev git

CURRENT_PATH=$(pwd)

# compile nginx-proxy
cd "$CURRENT_PATH/nginx"

# patch for http connect method
test -f auto/configure && mv auto/configure configure
patch -p1 <../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

test -d ${CURRENT_PATH}/nginx/objs && make clean
./configure \
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
    # --with-cc-opt='-static -static-libgcc' \
    # --with-ld-opt=-static
make

cp -r ${CURRENT_PATH}/nginx_debian ${CURRENT_PATH}/nginx_debian_${1}

# get execute file
test -d ${CURRENT_PATH}/nginx_debian/usr/sbin/ || mkdir -p ${CURRENT_PATH}/nginx_debian_${1}/usr/sbin/
cp ${CURRENT_PATH}/nginx/objs/nginx ${CURRENT_PATH}/nginx_debian_${1}/usr/sbin/nginx
cp ${CURRENT_PATH}/nginx/objs/nginx.8 ${CURRENT_PATH}/nginx_debian_${1}/usr/sbin/nginx.8

NGINX_VERSION_NUMBER=$(cat ${CURRENT_PATH}/nginx.version.number)
OPENSSL_VERSION=$(cat ${CURRENT_PATH}/openssl.version)

echo "[++] nginx_${NGINX_VERSION_NUMBER}.openssl_${OPENSSL_VERSION}.debian+${1}.amd64.deb"

# make deb package
cd ${CURRENT_PATH}
NG_PKG_SIZE=`du -sk nginx_debian_${1}|awk '{print $1}'`
NG_PKG_VERSION=${NGINX_VERSION_NUMBER}
test -d "nginx_debian_${1}/DEBIAN" || mkdir -p "nginx_debian_${1}/DEBIAN" 
sed -e "s|%%SIZE%%|${NG_PKG_SIZE}|" -e "s|%%VERSION%%|${NGINX_VERSION_NUMBER}|" < control_tmpl > nginx_debian_${1}/DEBIAN/control
test -d "nginx_debian_${1}/var/lib/nginx" || mkdir -p "nginx_debian_${1}/var/lib/nginx"        
test -d "nginx_debian_${1}/var/log/nginx" || mkdir -p "nginx_debian_${1}/var/log/nginx"
test -d "nginx_debian_${1}/var/www/html" || mkdir -p "nginx_debian_${1}/var/www/html"
test -d "nginx_debian_${1}/etc/nginx/modules-available" || mkdir -p "nginx_debian_${1}/etc/nginx/modules-available"
test -d "nginx_debian_${1}/etc/nginx/modules-enabled" || mkdir -p "nginx_debian_${1}/etc/nginx/modules-enabled"
test -d "nginx_debian_${1}/etc/nginx/conf.d" || mkdir -p "nginx_debian_${1}/etc/nginx/conf.d"
test -d "nginx_debian_${1}/etc/nginx/sites-enabled" || mkdir -p "nginx_debian_${1}/etc/nginx/sites-enabled"

dpkg -b "nginx_debian_${1}" "nginx_${NGINX_VERSION_NUMBER}.openssl_${OPENSSL_VERSION}.debian+${1}.amd64.deb"
test -d "${CURRENT_PATH}/release" || mkdir "${CURRENT_PATH}/release"
cp "nginx_${NGINX_VERSION_NUMBER}.openssl_${OPENSSL_VERSION}.debian+${1}.amd64.deb" "${CURRENT_PATH}/release/"
