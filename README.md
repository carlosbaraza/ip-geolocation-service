# IP Geolocaion service
This service will return the country code and country name for a given IPv4 using the
IP2Location Lite database.

## Development environment

```
./build.sh
docker run --name ip2location -p 5432:5432 ip2location-lite
npm start
```

## Run standalone Docker container
```
docker run --name ip2location -p 3000:3000/tcp ip2location-lite
```

then check it works with `curl http://localhost:3000?ip=8.8.8.8`

# Contributing
Thank you for checking this project out. Please, feel free to contribute to this codebase.

# License
Given that this service depends on the IP2Location database, and it is a propietary
database, the codebase is MIT licensed, but the database is propietary. If you
want to use it for commercial purposes, please consult with IP2Location to confirm that
would not cause any issues.