#!/bin/bash

date > .cachebust
docker build . -t ip2location-lite
rm .cachebust