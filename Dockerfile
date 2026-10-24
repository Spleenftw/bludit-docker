FROM php:8.3-apache
LABEL org.opencontainers.image.source="https://github.com/spleenftw/bludit-docker" \
      org.opencontainers.image.description="Unofficial Bludit build on the official PHP image" \
      org.opencontainers.image.licenses="MIT"

RUN sed -i 's|http://|https://|g' /etc/apt/sources.list.d/*.sources \
 && groupmod -g 82 www-data && usermod -u 82 www-data \
 && apt-get update && apt-get install -y --no-install-recommends \
      libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" gd \
 && a2enmod rewrite headers \
 && printf '<Directory /var/www/html>\n  AllowOverride All\n</Directory>\n' > /etc/apache2/conf-available/bludit.conf \
 && echo 'ServerName localhost' > /etc/apache2/conf-available/servername.conf \
 && a2enconf bludit servername \
 && rm -rf /var/lib/apt/lists/*

ARG BLUDIT_VERSION
ADD https://github.com/bludit/bludit/archive/refs/tags/${BLUDIT_VERSION}.tar.gz /tmp/b.tgz
RUN tar xzf /tmp/b.tgz --strip-components=1 -C /var/www/html \
 && rm /tmp/b.tgz \
 && mkdir -p /usr/src/bludit-defaults \
 && cp -a /var/www/html/bl-content /var/www/html/bl-plugins /var/www/html/bl-themes /usr/src/bludit-defaults/ \
 && chown -R www-data:www-data /var/www/html /usr/src/bludit-defaults

COPY --chmod=755 bludit-entrypoint.sh /usr/local/bin/bludit-entrypoint.sh
ENTRYPOINT ["bludit-entrypoint.sh"]
CMD ["apache2-foreground"]