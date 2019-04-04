FROM debian:stretch-slim

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq install wget unzip sudo gnupg curl supervisor
RUN wget --no-check-certificate https://www.postgresql.org/media/keys/ACCC4CF8.asc
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main' > /etc/apt/sources.list.d/pgdg.list
RUN apt-key add ACCC4CF8.asc
RUN apt-get update && apt-get -yq install postgresql-10

RUN mkdir -p /var/log/supervisor

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

# Update PostgreSQL settings
RUN echo "" >> /etc/postgresql/10/main/pg_hba.conf
RUN echo "host	all		all		0.0.0.0/0		md5" >> /etc/postgresql/10/main/pg_hba.conf
RUN sed -i -e "s/^#listen_addresses.*=.*/listen_addresses = '*'/" /etc/postgresql/10/main/postgresql.conf

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD . /app

ENV POSTGRESQL_PASSWORD 345

COPY .cachebust /tmp/cachebust
RUN /app/container-scripts/setup.sh

VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
# EXPOSE 5432 # Postgresql
EXPOSE 3000
CMD ["/usr/bin/supervisord"]