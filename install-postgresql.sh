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
sudo -u postgres "$INSTALL_PREFIX/bin/createdb" -h /tmp test
sudo -u postgres env LD_LIBRARY_PATH=/opt/pgsql/lib:$LD_LIBRARY_PATH "$INSTALL_PREFIX/bin/psql" -h /tmp test

#TODO alternatively set unix socket dir
#echo "unix_socket_directories = '/var/run/postgresql'" >> "$PGDATA/postgresql.conf"
#sudo mkdir -p /var/run/postgresql
#sudo chown postgres:postgres /var/run/postgresql
#sudo -u postgres "$INSTALL_PREFIX/bin/pg_ctl" -D "$PGDATA" restart

echo "# pgsql" >> ~/.bashrc
echo "PATH='$INSTALL_PREFIX/bin${PATH:+:${PATH}}'" >> ~/.bashrc
echo "LIBRARY_PATH='$INSTALL_PREFIX/lib${LIBRARY_PATH:+:${LIBRARY_PATH}}'" >> ~/.bashrc
echo "LD_LIBRARY_PATH='$INSTALL_PREFIX/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}'" >> ~/.bashrc
