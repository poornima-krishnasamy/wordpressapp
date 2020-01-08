FROM wordpress:php7.4-apache

COPY ./wp-content/themes/pktheme/ /usr/src/wordpress/wp-content/themes/pktheme

COPY ./vhosts.conf /etc/apache2/sites-available/000-default.conf

COPY ./ports.conf /etc/apache2/ports.conf

USER 33
