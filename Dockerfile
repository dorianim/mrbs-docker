FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.14

# versions
ARG MRBS_RELEASE=mrbs-1_9_4
ARG MODERN_MRBS_THEME_RELEASE=v0.2.0

LABEL maintainer="Dorian Zedler <mail@dorian.im>"

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
