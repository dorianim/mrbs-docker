FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.17-1fb28795-ls26

# versions
ARG MRBS_RELEASE=v1.11.4
ARG SIMPLESAMLPHP_RELEASE=1.19.8
ARG MODERN_MRBS_THEME_RELEASE=v0.4.1

LABEL maintainer="Dorian Zedler <mail@dorian.im>"

ENV MRBS_DB_SYSTEM="mysql"

RUN \
  echo "**** install packages ****" && \
  apk update && \
  apk add --no-cache  \
    curl \
    mysql-client \
    icu-libs \
    icu-data-full \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-gd \
    php81-ldap \
    php81-mbstring \
    php81-mysqlnd \
    php81-openssl \
    php81-pdo_mysql \
    php81-phar \
    php81-simplexml \
    php81-tokenizer \
    php81-intl \
    tar && \
  echo "**** configure php-fpm ****" && \
  sed -i 's/;clear_env = no/clear_env = no/g' /etc/php81/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php81/php-fpm.conf

RUN \
  echo "**** fetch mrbs ****" && \
  rm -rf /var/www/html && \
  mkdir -p /var/www/html && \
  curl -o /tmp/mrbs.tar.gz -L \
    "https://github.com/meeting-room-booking-system/mrbs-code/archive/${MRBS_RELEASE}.tar.gz" && \
  echo "**** extract only folder 'web' ****" && \
  tar -C /var/www/html --strip-components=2 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)web && \
  mkdir -p /usr/share/mrbs && \
  tar -C /usr/share/mrbs --wildcards --strip-components=1 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)tables.*.sql && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

RUN \
  echo "**** fetch simplesamlphp ****" && \
  mkdir -p /var/www/simplesamlphp && \
  curl -o \
  /tmp/simplesamlphp.tar.gz -L \
    "https://github.com/simplesamlphp/simplesamlphp/releases/download/v${SIMPLESAMLPHP_RELEASE}/simplesamlphp-${SIMPLESAMLPHP_RELEASE}.tar.gz" && \
  echo "**** extract simplesamlphp ****" && \
  tar -C /var/www/simplesamlphp --strip-components=1 -zxvf /tmp/simplesamlphp.tar.gz && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

RUN \
  echo "**** fetch modern-mrbs-theme ****" && \
  mkdir -p /var/www/html/Themes/modern && \
  curl -o /tmp/modern-mrbs-theme.tar.gz -L \
    "https://github.com/dorianim/modern-mrbs-theme/archive/${MODERN_MRBS_THEME_RELEASE}.tar.gz" && \
  echo "**** extract only folder 'modern' ****" && \
  tar -C /var/www/html/Themes/modern --strip-components=2 -zxvf /tmp/modern-mrbs-theme.tar.gz $(tar --exclude="*/*" -tf /tmp/modern-mrbs-theme.tar.gz)modern && \
  \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

COPY root/ /
VOLUME /config
EXPOSE 80
