FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.20

# versions
ARG MRBS_RELEASE=v1.11.5
ARG SIMPLESAMLPHP_RELEASE=1.19.8
ARG MODERN_MRBS_THEME_RELEASE=v0.4.2

LABEL maintainer="Dorian Zedler <mail@dorian.im>"

ENV MRBS_DB_SYSTEM="mysql"
ENV S6_STAGE2_HOOK="/init-hook"

RUN \
  echo "**** install runtime packages ****" && \
  apk update && \
  apk add --no-cache  \
    curl \
    mysql-client \
    icu-libs \
    icu-data-full \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-gd \
    php83-ldap \
    php83-mbstring \
    php83-mysqlnd \
    php83-openssl \
    php83-pdo_mysql \
    php83-phar \
    php83-simplexml \
    php83-tokenizer \
    php83-intl \
    tar && \
    echo "**** configure php-fpm to pass env vars ****" && \
    sed -E -i 's/^;?clear_env ?=.*$/clear_env = no/g' /etc/php83/php-fpm.d/www.conf && \
    grep -qxF 'clear_env = no' /etc/php83/php-fpm.d/www.conf || echo 'clear_env = no' >> /etc/php83/php-fpm.d/www.conf && \
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php83/php-fpm.conf

RUN \
  echo "**** fetch mrbs ****" && \
  rm -rf /app/www && \
  mkdir -p /app/www/public && \
  curl -o /tmp/mrbs.tar.gz -L \
    "https://github.com/meeting-room-booking-system/mrbs-code/archive/${MRBS_RELEASE}.tar.gz" && \

  echo "**** extract only folder 'web' ****" && \
  tar -C /app/www/public --strip-components=2 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)web && \
  mkdir -p /usr/share/mrbs && \
  tar -C /usr/share/mrbs --wildcards --strip-components=1 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)tables.*.sql && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

RUN \
  echo "**** fetch simplesamlphp ****" && \
  mkdir -p /app/www/simplesamlphp && \
  curl -o \
  /tmp/simplesamlphp.tar.gz -L \
    "https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SIMPLESAMLPHP_RELEASE}/simplesamlphp-${SIMPLESAMLPHP_RELEASE}.tar.gz" && \
  echo "**** extract simplesamlphp ****" && \
  tar -C /app/www/simplesamlphp --strip-components=1 -zxvf /tmp/simplesamlphp.tar.gz && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

RUN \
  echo "**** fetch modern-mrbs-theme ****" && \
  mkdir -p /app/www/public/Themes/modern && \
  curl -o /tmp/modern-mrbs-theme.tar.gz -L \
    "https://github.com/dorianim/modern-mrbs-theme/archive/${MODERN_MRBS_THEME_RELEASE}.tar.gz" && \
  echo "**** extract only folder 'modern' ****" && \
  tar -C /app/www/public/Themes/modern --strip-components=2 -zxvf /tmp/modern-mrbs-theme.tar.gz $(tar --exclude="*/*" -tf /tmp/modern-mrbs-theme.tar.gz)modern && \
  \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /
VOLUME /config
EXPOSE 80
