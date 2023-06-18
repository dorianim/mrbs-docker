FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.17

# versions
ARG MRBS_RELEASE=mrbs-1_11_0
ARG SIMPLESAMLPHP_RELEASE=1.19.8
ARG MODERN_MRBS_THEME_RELEASE=v0.4.0

LABEL maintainer="Dorian Zedler <mail@dorian.im>"

ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"
ENV MRBS_DB_SYSTEM="mysql"
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community musl-locales musl-locales-lang \
    && cd "$MUSL_LOCPATH" \
    && for i in *.UTF-8; do \
     i1=${i%%.UTF-8}; \
     i2=${i1/_/-}; \
     i3=${i/_/-}; \
     cp -a "$i" "$i1"; \
     cp -a "$i" "$i2"; \
     cp -a "$i" "$i3"; \
     done

RUN \
  echo "**** install packages ****" && \
  apk update && \
  apk add --no-cache  \
    curl \
    mysql-client \
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
  rm -rf /tmp/* && \
  echo "**** apply patches ****" && \
  sed -i '80s/parent::init();/parent::init($lifetime);/' /var/www/html/lib/MRBS/Session/SessionSaml.php
  # TODO: remove once it is fixed in MRBS

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
