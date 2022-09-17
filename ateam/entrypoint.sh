#!/bin/bash

# Precompile assets
bundle exec rake assets:precompile

# Wait for database to be ready
set -e

cmd="$@"
timer="5"

until nc -z -v -w30 $POSTGRES_HOST $POSTGRES_PORT; do
 echo 'Waiting for Postgres...'
 echo "$POSTGRES_HOST"
 sleep 1
done


echo "Postgres is up - executing command"
# env

export PGPASSWORD=$POSTGRES_PASSWORD
echo $POSTGRES_PASSWORD

psql \
   --host=$POSTGRES_HOST \
   --port=$POSTGRES_PORT \
   --username=$POSTGRES_USER \
   --password \
   --dbname=postgres

# If the database exists, migrate. Otherwise setup (create and migrate)
bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:create db:migrate
echo "Postgres database has been created & migrated!"

# Remove a potentially pre-existing server.pid for Rails.
rm -f tmp/pids/server.pid

# Run the Rails server
bundle exec rails server -b 0.0.0.0 -p 8080