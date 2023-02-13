FROM mysql:8.0.32

ARG MYSQL_ROOT_PASS

ENV MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASS}

EXPOSE 3306

COPY db/schema.sql /docker-entrypoint-initdb.d
