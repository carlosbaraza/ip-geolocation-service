# Geolocaion service

# Development environment

```
docker build . -t ip2location-lite
docker run --name ip2location -d -e POSTGRESQL_PASSWORD=1234 ip2location-lite
docker exec -it ip2location /usr/bin/psql -h localhost --username postgres -d ip2location_database
```


