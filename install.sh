test -d '$(DESTDIR)/usr/share/nginx' || mkdir -p '$(DESTDIR)/usr/share/nginx'

test -d '$(DESTDIR)/usr/sbin' \
  || mkdir -p '$(DESTDIR)/usr/sbin'
test ! -f '$(DESTDIR)/usr/sbin/nginx' \
  || mv '$(DESTDIR)/usr/sbin/nginx' \
    '$(DESTDIR)/usr/sbin/nginx.old'
cp objs/nginx '$(DESTDIR)/usr/sbin/nginx'

test -d '$(DESTDIR)/etc/nginx' \
  || mkdir -p '$(DESTDIR)/etc/nginx'

cp conf/koi-win '$(DESTDIR)/etc/nginx'
cp conf/koi-utf '$(DESTDIR)/etc/nginx'
cp conf/win-utf '$(DESTDIR)/etc/nginx'

test -f '$(DESTDIR)/etc/nginx/mime.types' \
  || cp conf/mime.types '$(DESTDIR)/etc/nginx'
cp conf/mime.types '$(DESTDIR)/etc/nginx/mime.types.default'

test -f '$(DESTDIR)/etc/nginx/fastcgi_params' \
  || cp conf/fastcgi_params '$(DESTDIR)/etc/nginx'
cp conf/fastcgi_params \
  '$(DESTDIR)/etc/nginx/fastcgi_params.default'

test -f '$(DESTDIR)/etc/nginx/fastcgi.conf' \
  || cp conf/fastcgi.conf '$(DESTDIR)/etc/nginx'
cp conf/fastcgi.conf '$(DESTDIR)/etc/nginx/fastcgi.conf.default'

test -f '$(DESTDIR)/etc/nginx/uwsgi_params' \
  || cp conf/uwsgi_params '$(DESTDIR)/etc/nginx'
cp conf/uwsgi_params \
  '$(DESTDIR)/etc/nginx/uwsgi_params.default'

test -f '$(DESTDIR)/etc/nginx/scgi_params' \
  || cp conf/scgi_params '$(DESTDIR)/etc/nginx'
cp conf/scgi_params \
  '$(DESTDIR)/etc/nginx/scgi_params.default'

test -f '$(DESTDIR)/etc/nginx/nginx.conf' \
  || cp conf/nginx.conf '$(DESTDIR)/etc/nginx/nginx.conf'
cp conf/nginx.conf '$(DESTDIR)/etc/nginx/nginx.conf.default'

test -d '$(DESTDIR)/run' \
  || mkdir -p '$(DESTDIR)/run'

test -d '$(DESTDIR)/var/log/nginx' \
  || mkdir -p '$(DESTDIR)/var/log/nginx'

test -d '$(DESTDIR)/usr/share/nginx/html' \
  || cp -R docs/html '$(DESTDIR)/usr/share/nginx'

test -d '$(DESTDIR)/var/log/nginx' \
  || mkdir -p '$(DESTDIR)/var/log/nginx'
