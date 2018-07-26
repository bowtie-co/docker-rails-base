#!/bin/bash

set -e

/scripts/wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT} --strict --timeout=60

exec "$@"