#!/usr/bin/env bash

source check-postgresql-dependencies.sh

INSTALL_PREFIX="/opt/pgsql"
PGDATA="$INSTALL_PREFIX/data"
LOG="$INSTALL_PREFIX/log"

git clone https://git.postgresql.org/git/postgresql.git
pushd postgresql
./configure --prefix="$INSTALL_PREFIX"
make -j18
sudo make install
popd
sudo adduser postgres
sudo mkdir -p "$PGDATA"
sudo mkdir -p "$LOG"
sudo chown -R postgres "$PGDATA"
sudo chown -R postgres "$LOG"
sudo -u postgres "$INSTALL_PREFIX/bin/initdb" -D "$PGDATA"
sudo -u postgres "$INSTALL_PREFIX/bin/pg_ctl" -D "$PGDATA" -l "$LOG/logfile" start
sudo -u postgres "$INSTALL_PREFIX/bin/createdb" test
sudo -u postgres "$INSTALL_PREFIX/bin/psql" test

