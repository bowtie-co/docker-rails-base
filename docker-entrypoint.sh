#!/bin/bash

log() {
  yellow='\033[0;33m'
  nocolor='\033[0m'
  prefix="======>>  "
  suffix="  <<======"
  echo
  echo -e "${yellow}${prefix}${1}${suffix}${nocolor}"
  echo
}

APP_ENV=${APP_ENV:-development}
RAILS_ENV=${RAILS_ENV:-$APP_ENV}
ENV_FILE=".env.$RAILS_ENV"
DOCKER_CMD=$(cat Dockerfile | grep CMD | awk '{ print $2 " " $3 " " $4 " " $5 " " $6 }')

if [ ! -f $ENV_FILE ]; then
  echo "Missing ENV file: $ENV_FILE"
  exit 1
fi

export $(sops -d $ENV_FILE | xargs)

./wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT} -t 30

if [[ "$RAILS_ENV" == "development" && "$@" == "/bin/sh -c $DOCKER_CMD" ]]; then
  log "Running database migration"

  bundle exec rake db:migrate

  if [[ "$?" != "0" ]]; then
    log "Migration failed! Running database setup"
    bundle exec rake db:setup
  fi

  ./wait-for-it.sh nginx:80 -t 30

  export TRUSTED_IP=$(getent hosts nginx | awk '{ print $1 }')
fi

exec "$@"
