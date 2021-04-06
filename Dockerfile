# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jballest <jballest@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2021/03/25 01:52:42 by jballest          #+#    #+#              #
#    Updated: 2021/03/31 02:49:46 by jballest         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

#   Package installation
RUN apt-get update && apt-get install -y \
    nginx mariadb-server php-mysql php-cli php-fpm php-xml php-mbstring wget unzip openssl

#   SSL Certificate signing
RUN openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=ES/ST=Spain/L=Madrid/O=42Madrid/CN=ft_server.jballest.42" \
    -keyout /etc/ssl/private/ft_server.jballest.key \
    -out /etc/ssl/certs/ft_server.jballest.cert

#   Configure nginx VirtualHost
COPY srcs/nginx/nginx_site /etc/nginx/sites-available/
RUN rm /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/nginx_site /etc/nginx/sites-enabled/nginx_site

#   Configure mariadb database for wordpress
RUN mkdir -p /tmp/mysql/
COPY srcs/mysql/wordpress.sql /tmp/mysql/
RUN service mysql start && \
    mysql -u root --password= < /tmp/mysql/wordpress.sql

#   Download wordpress and phpmyadmin
RUN cd /tmp && \
    wget https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz && \
    wget https://wordpress.org/latest.zip && \
    unzip latest.zip -d /var/www/html && \
    tar xzvf phpMyAdmin-5.1.0-all-languages.tar.gz -C /var/www/html && \
    mv /var/www/html/php* /var/www/html/phpmyadmin && \
    rm latest.zip phpMyAdmin-5.1.0-all-languages.tar.gz && \
    mkdir scripts

COPY srcs/wordpress/wp-config.php /var/www/html/wordpress/
COPY srcs/phpmyadmin/config.inc.php /var/www/html/phpmyadmin/
COPY srcs/scripts/toggle_autoindex.sh /tmp/scripts
COPY srcs/php/info.php /var/www/html/
COPY srcs/html/index_jballest.html /var/www/html/
RUN chown www-data:www-data /var/www/html
RUN chmod -R +x /tmp/scripts/

# Expose this ports to be able to access the container's ports
# from our host machine.
# Port 80 ===> http
# Port 443 ===> https
EXPOSE 80 443

ENTRYPOINT service php7.3-fpm start && \
            service mysql start && \
            ./tmp/scripts/toggle_autoindex.sh init && \
            sleep infinity
