FROM postgres:14

ENV POSTGRES_HOST_AUTH_METHOD=trust
EXPOSE 5432

COPY sql/* /docker-entrypoint-initdb.d/
COPY examples/example.sql /docker-entrypoint-initdb.d/

USER postgres
