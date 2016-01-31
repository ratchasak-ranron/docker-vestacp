FROM babim/ubuntubaseinit:ssh

RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install git unzip nano

ADD install-ubuntu.sh /install-ubuntu.sh
RUN chmod +x /install-ubuntu.sh

RUN bash /install-ubuntu.sh \
 --nginx yes --apache yes --phpfpm no \
 --vsftpd no --proftpd no \
 --exim yes --dovecot yes --spamassassin no --clamav no \
 --named yes \
 --iptables no --fail2ban no \
 --mysql yes --postgresql no \
 --remi yes \
 --quota no \
 --password admin \
 -y no -f

ADD dovecot /etc/init.d/dovecot
RUN chmod +x /etc/init.d/dovecot

RUN cd /usr/local/vesta/data/ips && mv * 127.0.0.1 \
    && cd /etc/apache2/conf.d && sed -i -- 's/172.*.*.*:80/127.0.0.1:80/g' * && sed -i -- 's/172.*.*.*:8443/127.0.0.1:8443/g' * \
    && cd /etc/nginx/conf.d && sed -i -- 's/172.*.*.*:80 default;/80 default;/g' * && sed -i -- 's/172.*.*.*:8080/127.0.0.1:8080/g' *

RUN apt-get -y purge php5 \
    && apt-get -y install python-software-properties language-pack-en-base \
    && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php-7.0 -y \
    && LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/apache2 -y \
    && apt-get update \
    && apt-get install -y php7.0 \
    && apt-get install -y \
    php7.0-common libapache2-mod-php7.0 php7.0-cgi php7.0-cli php7.0-phpdbg libphp7.0-embed php7.0-dev php7.0-dbg php7.0-curl \
    php7.0-gd php7.0-imap php7.0-interbase php7.0-intl php7.0-ldap php7.0-mcrypt php7.0-readline php7.0-odbc php7.0-pgsql \
    php7.0-pspell php7.0-recode php7.0-tidy php7.0-xmlrpc php7.0 php7.0-json php-all-dev php7.0-sybase php7.0-modules-source \
    php7.0-sqlite3 php7.0-mysql php7.0-opcache php7.0-bz2 \
    && rm -rf /etc/apache2/mods-enabled/php5.conf \
    && rm -rf /etc/apache2/mods-enabled/php5.load

RUN mkdir /vesta-start \
    && mkdir /vesta-start/etc \
    && mkdir /vesta-start/var \
    && mkdir /vesta-start/local \
    && mv /home /vesta-start/home \
    && rm -rf /home \
    && ln -s /vesta/home /home \
    && mv /etc/apache2 /vesta-start/etc/apache2 \
    && rm -rf /etc/apache2 \
    && ln -s /vesta/etc/apache2 /etc/apache2 \
    && mv /etc/php   /vesta-start/etc/php \
    && rm -rf /etc/php \
    && ln -s /vesta/etc/php /etc/php \
    && mv /etc/nginx   /vesta-start/etc/nginx \
    && rm -rf /etc/nginx \
    && ln -s /vesta/etc/nginx /etc/nginx \
    && mv /etc/bind    /vesta-start/etc/bind \
    && rm -rf /etc/bind \
    && ln -s /vesta/etc/bind /etc/bind \
    && mv /etc/exim4   /vesta-start/etc/exim4 \
    && rm -rf /etc/exim4 \
    && ln -s /vesta/etc/exim4 /etc/exim4 \
    && mv /etc/dovecot /vesta-start/etc/dovecot \
    && rm -rf /etc/dovecot \
    && ln -s /vesta/etc/dovecot /etc/dovecot \
    && mv /etc/mysql   /vesta-start/etc/mysql \
    && rm -rf /etc/mysql \
    && ln -s /vesta/etc/mysql /etc/mysql \
    && mv /etc/phpmyadmin  /vesta-start/etc/phpmyadmin \
    && rm -rf /etc/phpmyadmin \
    && ln -s /vesta/etc/phpmyadmin /etc/phpmyadmin \
    && mv /root /vesta-start/root \
    && rm -rf /root \
    && ln -s /vesta/root /root \
    && mv /usr/local/vesta /vesta-start/local/vesta \
    && rm -rf /usr/local/vesta \
    && ln -s /vesta/local/vesta /usr/local/vesta \
    && mv /var/log /vesta-start/var/log \
    && rm -rf /var/log \
    && ln -s /vesta/var/log /var/log

RUN apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
    
VOLUME /vesta

RUN mkdir -p /etc/my_init.d
ADD startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

EXPOSE 22 80 8083 3306 443 25 993 110 53 54
