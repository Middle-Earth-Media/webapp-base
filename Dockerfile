FROM alpine:3.16

# Install packages and remove default server definition
RUN apk --no-cache add \
  build-base \
  curl \
  nginx \
  php8 \
  php8-ctype \
  php8-curl \
  php8-dom \
  php8-dev \
  php8-fileinfo \
  php8-fpm \
  php8-gd \
  php8-intl \
  php8-json \
  php8-mbstring \
  php8-mysqli \
  php8-opcache \
  php8-openssl \
  php8-phar \
  php8-pdo \
  php8-pdo_mysql \
  php8-session \
  php8-simplexml \
  php8-tokenizer \
  php8-xml \
  php8-xmlreader \
  php8-xmlwriter \
  php8-zlib \
  php8-zip \
  supervisor

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
#RUN  rm /etc/nginx/conf.d/default.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php8/php-fpm.d/www.conf
COPY config/php.ini /etc/php8/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

RUN addgroup -S webuser && adduser -S webuser -G webuser
RUN chown -R webuser.webuser /var/www/html && \
  chown -R webuser.webuser /run && \
  chown -R webuser.webuser /var/lib/nginx && \
  chown -R webuser.webuser /var/log/nginx
USER webuser

# Add application
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]