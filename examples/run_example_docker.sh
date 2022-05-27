#!/bin/bash
set -e

cd ..
docker build -t pgtrail_example -f examples/Dockerfile .
docker run -it --rm --name pgtrail_example_01 -p 5432:5432 -d pgtrail_example postgres
sleep 5s
docker exec -it pgtrail_example_01 psql -U postgres