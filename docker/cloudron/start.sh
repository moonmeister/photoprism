#!/bin/bash

set -eu

# ensure that data directory is owned by 'cloudron' user
echo "Ensuring files are owned by cloudron user"
chown -R cloudron.cloudron /app/data

if [[ ! -f /app/data/.initialized ]]; then
  echo "Fresh installation, setting up data directory..."
  # Setup commands here
  touch /app/data/.initialized

  mkdir -p \
    /app/data/backup \
    /app/data/originals \
    /app/data/import \
    /app/data/storage/config \
    /app/data/storage/cache

    # chmod -Rf a+rw /app/data /tmp/photoprism

  echo "Done."
fi


echo "Setting PhotoPrism env Vars"
export PHOTOPRISM_SITE_URL=$CLOUDRON_APP_ORIGIN \
  PHOTOPRISM_DATABASE_SERVER=$CLOUDRON_MYSQL_HOST:$CLOUDRON_MYSQL_PORT \
  PHOTOPRISM_DATABASE_NAME=$CLOUDRON_MYSQL_DATABASE \
  PHOTOPRISM_DATABASE_USER=$CLOUDRON_MYSQL_USERNAME \
  PHOTOPRISM_DATABASE_PASSWORD=$CLOUDRON_MYSQL_PASSWORD

# run the app as user 'cloudron'
exec gosu cloudron:cloudron photoprism start