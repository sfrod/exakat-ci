FROM php:7.4-buster

LABEL MAINTAINER="Sergio Rodrigues <frod.contact@gmail.com>"

ENV EXAKAT_VERSION 2.0.6
ENV GREMLIN_VERSION 3.4.6
ENV GREMLIN_NEO4J_VERSION 3.4.6
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src/exakat/
COPY script/entrypoint.sh entrypoint.sh
COPY config/exakat.ini /usr/src/exakat/config/

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN php --version
RUN mkdir -p /usr/share/man/man1 ;\
    apt-get update ;\
    apt-get install apt-utils software-properties-common --no-install-recommends -yq ;\
    apt-get install -yq autoconf \
    automake \
    autotools-dev \
    build-essential \
    ca-certificates \
    curl \
    default-jre \
    gettext \
    git \
    libbz2-dev \
    libcurl4-gnutls-dev \
    libfreetype6-dev \
    libgd-dev \
    libicu-dev \
    libjpeg-dev \
    libltdl-dev \
    libmcrypt-dev \
    libmhash-dev \
    libonig-dev \
    libpng-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxpm4 \
    libxslt-dev \
    libzip-dev \
    lsof \
    mercurial \
    openssl \
    procps \
    re2c \
    subversion \
    tar \
    unzip \
    wget \
    zlib1g-dev ;\
    docker-php-ext-install -j$(nproc) bz2 \
    gettext \
    zip

RUN echo "===> Get PHP Composer" ;\
    curl -sS https://getcomposer.org/installer -o composer-setup.php ;\
    HASH="$(curl --silent -o - https://composer.github.io/installer.sig)" ;\
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" ;\
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN echo "===> Installing Phpbrew..." ;\
    curl -L -O https://github.com/phpbrew/phpbrew/releases/latest/download/phpbrew.phar ;\
    chmod +x phpbrew.phar ;\
    mv phpbrew.phar /usr/local/bin/phpbrew ;\
    echo "===> Phpbrew init..." ;\
    phpbrew init ;\
    echo "source ~/.phpbrew/bashrc" >> ~/.bashrc ;\
    echo "source ~/.bashrc" >> ~/.bashrc ;\
    echo "===> Updating the release list from official php site..." ;\
    phpbrew update ;\
    phpbrew known ;\
    echo "===> Installing Recommended Php versions for Exakat..." ;\
    phpbrew install 7.3 as php-7.3 like php-7.3 +cli +tokenizer +mbstring ;\
    phpbrew install 7.2 as php-7.2 like php-7.2 +cli +tokenizer +mbstring ;\
    phpbrew install 7.1 as php-7.1 like php-7.1 +cli +tokenizer +mbstring ;\
    phpbrew install 7.0 as php-7.0 like php-7.0 +cli +tokenizer +mbstring ;\
    phpbrew install 5.6 as php-5.6 like php-5.6 +cli +tokenizer +mbstring 

RUN echo "====> Get Exakat..." ;\
    curl -o exakat.phar http://dist.exakat.io/version/index.php?file=exakat-$EXAKAT_VERSION.phar ;\
    chmod a+x /usr/src/exakat/exakat.phar

RUN echo "====> Gremlin-Server..." ;\
    curl -o apache-tinkerpop-gremlin-server-$GREMLIN_VERSION-bin.zip https://mirrors.up.pt/pub/apache/tinkerpop/$GREMLIN_VERSION/apache-tinkerpop-gremlin-server-$GREMLIN_VERSION-bin.zip ;\
    unzip apache-tinkerpop-gremlin-server-$GREMLIN_VERSION-bin.zip ;\
    mv apache-tinkerpop-gremlin-server-$GREMLIN_VERSION tinkergraph ;\
    rm -rf apache-tinkerpop-gremlin-server-$GREMLIN_VERSION-bin.zip ;\
    echo "====> Installing Neo4j engine..." ;\
    cd tinkergraph ;\
    bin/gremlin-server.sh install org.apache.tinkerpop neo4j-gremlin 3.4.6 ;\
    cd .. 

RUN echo "====> Clean UP..." ;\
    apt-get clean ;\
    rm -rf /var/lib/apt/lists/* ;\
    php exakat.phar doctor ;\
    chmod +x entrypoint.sh  ;\
    mkdir /report 
    
ENTRYPOINT ["./entrypoint.sh"]