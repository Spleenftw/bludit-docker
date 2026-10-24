#!/bin/sh
set -e
for d in bl-content bl-plugins bl-themes; do
  target="/var/www/html/$d"
  if [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
    cp -a "/usr/src/bludit-defaults/$d/." "$target/"
    chown -R www-data:www-data "$target"
  fi
done
exec docker-php-entrypoint "$@"