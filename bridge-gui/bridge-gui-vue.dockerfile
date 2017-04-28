#
# Based on https://github.com/KyleAMathews/docker-nginx
#
FROM kyma/docker-nginx

COPY ./bridge-gui-vue/dist /var/www/

RUN ln -s /etc/nginx/sites-available/default-ssl /etc/nginx/sites-enabled

COPY ./files/scripts/inject_static_secrets /usr/local/bin/inject_static_secrets
COPY ./files/scripts/start-bridge-gui /usr/local/bin/start-bridge-gui

WORKDIR /etc/nginx

CMD ["/usr/local/bin/start-bridge-gui"]
