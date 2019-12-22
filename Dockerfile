FROM wordpress:latest

ENV WORDPRESS_DB_HOST=db:3306 \
    WORDPRESS_DB_USER=wordpress_user \
    WORDPRESS_DB_PASSWORD=wordpress_password \
    WORDPRESS_DB_NAME=wordpress

COPY ./wordpress/wp-content/themes/pktheme/ /usr/src/wordpress/wp-content/themes/pktheme

WORKDIR /var/www/html

USER www-data


