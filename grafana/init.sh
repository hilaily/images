#!/bin/sh
docker pull grafana/grafana
basedir=$(cd `dirname $0`;pwd)

docker stop grafana
docker rm grafana
docker run -d --name grafana  -p 3000:3000 grafana/grafana grafana