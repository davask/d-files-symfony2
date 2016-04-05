FROM davask/d-files
MAINTAINER davask <contact@davaskweblimited.com>

LABEL dwl.files.framework="symfony2"

# disable interactive functions
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get install -y \
php5 \
curl \
acl

RUN curl -sS https://getcomposer.org/installer | php;
RUN mv composer.phar /usr/local/bin/composer;

COPY ./dwl-setup-1-update-symfony.sh /tmp/dwl-setup-1-update-symfony.sh
