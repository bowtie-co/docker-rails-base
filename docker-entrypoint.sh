#!/bin/bash

set -e

./wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT} --strict --timeout=60

exec "$@"