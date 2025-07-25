#!/usr/bin/env bash

PGDB="/home/postgres/db"
PGDATA="$PGDB/data"
LOG="$PGDB/log"

## add user
#sudo adduser postgres
sudo -u postgres mkdir -p "$PGDB"
sudo -u postgres mkdir -p "$LOG"
sudo -u postgres mkdir -p /var/run/postgresql
sudo chown -R postgres:postgres /var/run/postgresql

# create empty db
sudo -u postgres initdb -D "$PGDATA"
# set socket path
echo "unix_socket_directories = '/var/run/postgresql'" | sudo -u postgres tee -a "$PGDATA/postgresql.conf" > /dev/null
# start
sudo -u postgres pg_ctl -D "$PGDATA" -l "$LOG/logfile" start
# test
sudo -u postgres createdb -h /var/run/postgresql test
sudo -u postgres psql -h /var/run/postgresql test

# restart postgres
#sudo -u postgres pg_ctl -D /home/postgres/db/data stop
#sudo -u postgres pg_ctl -D "$PGDATA" -l "$LOG/logfile" start
