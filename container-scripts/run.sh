#!/bin/bash

# TODO: Add supervisord https://riptutorial.com/docker/example/14132/dockerfile-plus-supervisord-conf

# turn on bash's job control
set -m

# Start the postgress process and put it in the background
su postgres -c "/usr/lib/postgresql/10/bin/postgres -D /var/lib/postgresql/10/main -c config_file=/etc/postgresql/10/main/postgresql.conf 2> /var/log/postgresql/postgresql-10-main.log"

# sleep 5
# sudo -u postgres psql -U postgres -d ip2location_database -c 'DROP FUNCTION IF EXISTS inet_to_bigint(inet);CREATE OR REPLACE FUNCTION inet_to_bigint(inet) RETURNS bigint AS $$ SELECT $1 - inet '\''0.0.0.0'\'' $$ LANGUAGE SQL strict immutable;GRANT execute ON FUNCTION inet_to_bigint(inet) TO public;' > /dev/null

# now we bring the primary process back into the foreground
# and leave it there
# fg %1