# Meta API images (ADR-047). Two targets:
#
#   docker build -t nard-api:dev apps/api                         # dev (default)
#   docker build --target production -t nard-api:prod apps/api    # production
#
# `dev` is the LAST stage on purpose: a build without --target (compose,
# the CLAUDE.md checks) keeps getting the dev image with dev dependencies.
# BuildKit only builds the stages the chosen target needs.

# ---------------------------------------------------------------------------
# Production: FrankenPHP (Caddy + PHP in one process, classic mode) serving
# public/ on :8000, no dev dependencies, opcache without timestamp checks,
# non-root uid 10001. Designed for a read-only root: only /app/storage and
# /tmp must be writable (emptyDir volumes in the Helm chart).
# ---------------------------------------------------------------------------
FROM dunglas/frankenphp:1.12.7-php8.3-alpine AS prod-base

# pdo_mysql (MySQL), redis (phpredis: cache, readiness), intl (Filament
# number/date formatting), zip (account export, AccountExport), pcntl
# (queue:work timeouts and signals), bcmath, opcache.
RUN install-php-extensions pdo_mysql redis intl zip pcntl bcmath opcache \
    && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    # The image grants CAP_NET_BIND_SERVICE as a file capability; we listen
    # on 8000 and the pods drop every capability, so remove it (a file
    # capability outside the bounding set makes exec fail).
    && apk add --no-cache --virtual .setcap libcap-utils \
    && setcap -r /usr/local/bin/frankenphp \
    && apk del .setcap \
    && addgroup -S -g 10001 nard \
    && adduser -S -D -H -u 10001 -G nard -s /sbin/nologin nard

COPY docker/php.ini "$PHP_INI_DIR/conf.d/zz-nard.ini"
COPY docker/Caddyfile /etc/frankenphp/Caddyfile
COPY --chmod=755 docker/entrypoint.sh /usr/local/bin/nard-entrypoint

FROM prod-base AS prod-build
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --no-scripts --no-autoloader \
        --prefer-dist --no-progress
COPY . .
# Equivalent to `composer install --no-dev --optimize-autoloader
# --classmap-authoritative`, split so the vendor layer is cached. The
# post-autoload-dump scripts rediscover packages without dev ones and
# publish Filament's assets into public/.
#
# Baked caches are env-independent: routes, events, Filament components and
# Blade icons. NOT config:cache — configuration comes from the environment
# at runtime. NOT view:cache — compiled views live in storage/, which is a
# writable volume in production.
RUN rm -rf tests phpunit.xml phpstan.neon .phpunit.cache public/.htaccess \
        AGENTS.md CLAUDE.md README.md Dockerfile docker package.json vite.config.js \
        storage/framework/views/* storage/logs/* \
    && composer dump-autoload --no-dev --optimize --classmap-authoritative --no-interaction \
    && php artisan route:cache \
    && php artisan event:cache \
    && php artisan filament:optimize \
    && rm /usr/bin/composer

FROM prod-base AS production
WORKDIR /app
COPY --from=prod-build /app /app
# Code stays root-owned and read-only for the app user; only storage/ is
# writable (and replaced by a volume on a read-only root).
RUN chown -R nard:nard /app/storage
ENV XDG_CONFIG_HOME=/tmp/caddy/config \
    XDG_DATA_HOME=/tmp/caddy/data \
    FRANKENPHP_NUM_THREADS=8
USER 10001:10001
EXPOSE 8000
# The entrypoint recreates storage/'s layout when storage/ is an empty
# volume, then runs the command: the web server by default, or any
# `php artisan …` (scheduler, queue worker, migrations). In Kubernetes pass
# those as `args`, not `command`, so the entrypoint still runs.
ENTRYPOINT ["nard-entrypoint"]
CMD ["frankenphp", "run", "--config", "/etc/frankenphp/Caddyfile", "--adapter", "caddyfile"]

# ---------------------------------------------------------------------------
# Development / CI (default target): dev dependencies, runs as root, used by
# infra/docker-compose.yml and the API checks in CLAUDE.md.
# ---------------------------------------------------------------------------
FROM php:8.3-cli-alpine AS dev

RUN apk add --no-cache $PHPIZE_DEPS icu-dev libzip-dev linux-headers \
    && docker-php-ext-install pdo_mysql intl zip pcntl bcmath \
    && pecl install redis \
    && docker-php-ext-enable redis

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/api
COPY composer.json composer.lock ./
RUN composer install --no-interaction --no-scripts --no-autoloader --prefer-dist
COPY . .
RUN composer dump-autoload --optimize

EXPOSE 8000
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
