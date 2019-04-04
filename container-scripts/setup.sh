#!/bin/bash

error() { echo -e "\e[91m$1\e[m"; exit 0; }
success() { echo -e "\e[92m$1\e[m"; }

echo -n ' > Create directory /_tmp '
mkdir /_tmp

[ ! -d /_tmp ] && error '[ERROR]' || success '[OK]'

cd /_tmp

echo -n ' > Download IP2Location package '
wget -O database.zip -q --user-agent="Docker-IP2Location/PostgreSQL" https://download.ip2location.com/lite/IP2LOCATION-LITE-DB1.CSV.ZIP 2>&1

[ ! -f database.zip ] && error '[ERROR]'

[ ! -z "$(grep 'NO PERMISSION' database.zip)" ] && error '[DENIED]'

[ ! -z "$(grep '5 times' database.zip)" ] && error '[QUOTE EXCEEDED]'

[ $(wc -c < database.zip) -lt 102400 ] && error '[ERROR]'

echo -n ' > Decompress downloaded package '

unzip -q -o database.zip

CSV="$(find . -name 'IP2LOCATION-LITE-DB*.CSV')"

# CSV="$(find . -name 'IP2LOCATION-LITE-DB*.IPV6.CSV')"


[ -z "$CSV" ] && error '[ERROR]' || success '[OK]'

service postgresql start >/dev/null 2>&1

echo -n ' > [PostgreSQL] Create database "ip2location_database" '

RESPONSE="$(sudo -u postgres createdb ip2location_database 2>&1)"

[ ! -z "$(echo $RESPONSE | grep 'FATAL')" ] && error '[ERROR]' || success '[OK]'

echo -n ' > [PostgreSQL] Create table "ip2location_database_tmp" '

FIELDS=''


RESPONSE="$(sudo -u postgres psql -c 'CREATE TABLE ip2location_database_tmp (ip_from decimal(39,0) NOT NULL,ip_to decimal(39,0) NOT NULL,country_code CHARACTER(2) NOT NULL,country_name varchar(64) NOT NULL'"$FIELDS"');' ip2location_database 2>&1)"
# RESPONSE="$(sudo -u postgres psql -c 'CREATE TABLE ip2location_database_tmp (ip_from bigint NOT NULL,ip_to bigint NOT NULL,country_code CHARACTER(2) NOT NULL,country_name varchar(64) NOT NULL,region_name varchar(128) NOT NULL,city_name varchar(128) NOT NULL,latitude varchar(20) NOT NULL,longitude varchar(20) NOT NULL,zip_code varchar(30) NULL DEFAULT NULL,time_zone varchar(8) NULL DEFAULT NULL,isp varchar(255) NOT NULL,domain varchar(128) NOT NULL,net_speed varchar(8) NOT NULL,idd_code varchar(5) NOT NULL,area_code varchar(30) NOT NULL,weather_station_code varchar(10) NOT NULL,weather_station_name varchar(128) NOT NULL,mcc varchar(128) NULL DEFAULT NULL,mnc varchar(128) NULL DEFAULT NULL,mobile_brand varchar(128) NULL DEFAULT NULL,elevation integer NOT NULL,usage_type varchar(11) NOT NULL);' ip2location_database 2>&1)"


[ -z "$(echo $RESPONSE | grep 'CREATE TABLE')" ] && error '[ERROR]' || success '[OK]'

sudo -u postgres psql -c 'CREATE INDEX idx_ip_to ON ip2location_database_tmp USING btree (ip_to) WITH (FILLFACTOR=100);' ip2location_database > /dev/null

echo -n ' > [PostgreSQL] Import CSV data into "ip2location_database_tmp" '

RESPONSE="$(sudo -u postgres psql -c 'COPY ip2location_database_tmp FROM '\'''/_tmp/IP2LOCATION-LITE-DB1.CSV''\'' WITH CSV QUOTE AS '\''"'\'';' ip2location_database 2>&1)"

[ -z "$(echo $RESPONSE | grep 'COPY')" ] && error '[ERROR]' || success '[OK]'

echo ' > [PostgreSQL] Drop table "ip2location_database" '

RESPONSE="$(sudo -u postgres psql -c 'DROP TABLE IF EXISTS ip2location_database;' ip2location_database 2>&1)"

[ ! -z "$(echo $RESPONSE | grep 'ERROR')" ] && error '[ERROR]' || success '[OK]'

echo ' > [PostgreSQL] Rename table "ip2location_database_tmp" to "ip2location_database" '

RESPONSE="$(sudo -u postgres psql -c 'ALTER TABLE ip2location_database_tmp RENAME TO ip2location_database;' ip2location_database 2>&1)"

[ ! -z "$(echo $RESPONSE | grep 'ERROR')" ] &&  error '[ERROR]' || success '[OK]'

echo ' > [PostgreSQL] Update PostgreSQL password for user "postgres" '

if [ "$POSTGRESQL_PASSWORD" != "FALSE" ]; then
	DBPASS="$POSTGRESQL_PASSWORD"
else
	DBPASS="$(< /dev/urandom tr -dc A-Za-z0-9 | head -c8)"	
fi

sudo -u postgres psql -U postgres -d postgres -c "ALTER USER postgres WITH PASSWORD '$DBPASS';" > /dev/null
sudo -u postgres psql -U postgres -d ip2location_database -c 'CREATE OR REPLACE FUNCTION inet_to_bigint(inet) RETURNS bigint AS $$ SELECT $1 - inet '\''0.0.0.0'\'' $$ LANGUAGE SQL strict immutable;GRANT execute ON FUNCTION inet_to_bigint(inet) TO public;' > /dev/null

echo " > Setup completed"
echo ""
echo " > You can now connect to this PostgreSQL Server using:"
echo ""
echo "   psql -h HOST -p PORT --username=postgres"
echo "   Enter the password '$DBPASS' when prompted"
echo ""

# rm -rf /_tmp
echo '' > /setup_done
service postgresql stop >/dev/null 2>&1