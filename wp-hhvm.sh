#!/usr/bin/env bash

FILE=latest.tar.gz
FOLDER=wordpress

HTTP_PORT=8080

mysql_up() {
    docker kill wp-mysql
    docker rm wp-mysql
    docker run \
	   --net=host \
	   --name wp-mysql \
	   -e MYSQL_ROOT_PASSWORD=secret \
	   -d mysql:8 \
	&& echo MySQL is up

}

[[ ! -e "$FILE" ]] && \
    wget "https://wordpress.org/$FILE"

[[ ! -d $FOLDER ]] && \
    tar xzf "$FILE"

mysql_up

ab_test() {
}

(
    cd $FOLDER;
    hhvm --mode server --port $HTTP_PORT
    ab -n 1000 -c 10 http://localhost:$HTTP_PORT/

    # php -S localhost:$HTTP_PORT -t ./
    # ab_test && kill $PID
)
