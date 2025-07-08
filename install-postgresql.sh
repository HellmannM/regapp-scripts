#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Check deps #################################################################
source "$SCRIPTS_DIR/check-postgresql-dependencies.sh"

INSTALL_PREFIX="/opt/pgsql"
PGDB="$INSTALL_PREFIX/db"
PGDATA="$PGDB/data"
LOG="$PGDB/log"

# clone and build
git clone https://git.postgresql.org/git/postgresql.git
pushd postgresql
./configure --prefix="$INSTALL_PREFIX"
make -j18
sudo make install
popd

# add user
sudo adduser postgres
sudo mkdir -p "$PGDB"
sudo mkdir -p "$LOG"
sudo mkdir -p /var/run/postgresql
sudo chown -R postgres:postgres "$PGDB"
sudo chown -R postgres:postgres "$LOG"
sudo chown -R postgres:postgres /var/run/postgresql

# create empty db
sudo -u postgres "$INSTALL_PREFIX/bin/initdb" -D "$PGDATA"
# set socket path
echo "unix_socket_directories = '/var/run/postgresql'" | sudo -u postgres tee -a "$PGDATA/postgresql.conf" > /dev/null
# start
sudo -u postgres "$INSTALL_PREFIX/bin/pg_ctl" -D "$PGDATA" -l "$LOG/logfile" start
# test
sudo -u postgres "$INSTALL_PREFIX/bin/createdb" -h /var/run/postgresql test
sudo -u postgres env LD_LIBRARY_PATH=/opt/pgsql/lib:$LD_LIBRARY_PATH "$INSTALL_PREFIX/bin/psql" -h /var/run/postgresql test

# add to bashrc
echo "Adding $INSTALL_PREFIX to PATH, LIBRARY_PATH and LD_LIBRARY_PATH in ~/.bashrc"
echo "# pgsql" >> ~/.bashrc
echo "PATH='$INSTALL_PREFIX/bin${PATH:+:${PATH}}'" >> ~/.bashrc
echo "LIBRARY_PATH='$INSTALL_PREFIX/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}'" >> ~/.bashrc
echo "LD_LIBRARY_PATH='$INSTALL_PREFIX/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'" >> ~/.bashrc
