#!/bin/bash
docker pull petergrace/opentsdb-docker
docker run -dp 4242:4242 petergrace/opentsdb-docker
