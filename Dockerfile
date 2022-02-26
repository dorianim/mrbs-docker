FROM ghcr.io/linuxserver/baseimage-alpine-nginx:2021.11.04

# versions
ARG MRBS_RELEASE=mrbs-1_10_0
ARG MODERN_MRBS_THEME_RELEASE=v0.3.3

LABEL maintainer="Dorian Zedler <mail@dorian.im>"

ENV MUSL_LOCPATH="/usr/share/i18n/locales/musl"
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
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-gd \
    php7-ldap \
    php7-mbstring \
    php7-memcached \
    php7-mysqlnd \
    php7-openssl \
    php7-pdo_mysql \
    php7-phar \
    php7-simplexml \
    php7-tokenizer \
    php7-intl \
    tar && \
  echo "**** configure php-fpm ****" && \
  sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
  echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf

RUN \
  echo "**** fetch mrbs ****" && \
  rm -rf /var/www/html && \
  mkdir -p\
    /var/www/html && \
  if [ -z ${MRBS_RELEASE+x} ]; then \
    MRBS_RELEASE=$(curl -sX GET "https://api.github.com/repos/meeting-room-booking-system/mrbs-code/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/mrbs.tar.gz -L \
    "https://github.com/meeting-room-booking-system/mrbs-code/archive/${MRBS_RELEASE}.tar.gz" && \
  echo "**** extract only folder 'web' ****" && \
  tar -C /var/www/html --strip-components=2 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)web && \
  mkdir -p /usr/share/mrbs && \
  tar -C /usr/share/mrbs --strip-components=1 -zxvf /tmp/mrbs.tar.gz $(tar --exclude="*/*" -tf /tmp/mrbs.tar.gz)tables.my.sql && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

 RUN \
  echo "**** fetch modern-mrbs-theme ****" && \
  mkdir -p /var/www/html/Themes/modern && \
  if [ -z ${MODERN_MRBS_THEME_RELEASE+x} ]; then \
    MODERN_MRBS_THEME_RELEASE=$(curl -sX GET "https://api.github.com/repos/dorianim/modern-mrbs-theme/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
  /tmp/modern-mrbs-theme.tar.gz -L \
    "https://github.com/dorianim/modern-mrbs-theme/archive/${MODERN_MRBS_THEME_RELEASE}.tar.gz" && \
  echo "**** extract only folder 'modern' ****" && \
  tar -C /var/www/html/Themes/modern --strip-components=2 -zxvf /tmp/modern-mrbs-theme.tar.gz $(tar --exclude="*/*" -tf /tmp/modern-mrbs-theme.tar.gz)modern && \
  \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

COPY root/ /

VOLUME /config
EXPOSE 80
