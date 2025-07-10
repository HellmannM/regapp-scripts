#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Check deps #################################################################
source "$SCRIPTS_DIR/check-postgresql-dependencies.sh"

INSTALL_PREFIX="/opt/pgsql"

# clone and build
git clone https://git.postgresql.org/git/postgresql.git
pushd postgresql
./configure --prefix="$INSTALL_PREFIX"
make -j18
sudo make install
popd

# add to bashrc
echo "Adding $INSTALL_PREFIX to PATH, LIBRARY_PATH and LD_LIBRARY_PATH in ~/.bashrc"
echo "\n#pgsql" >> ~/.bashrc
echo "PATH=\"$INSTALL_PREFIX/bin\${PATH:+:\${PATH}}\"" >> ~/.bashrc
echo "LIBRARY_PATH=\"$INSTALL_PREFIX/lib\${PATH:+:\${PATH}}\"" >> ~/.bashrc
echo "LD_LIBRARY_PATH=\"$INSTALL_PREFIX/lib\${PATH:+:\${PATH}}\"" >> ~/.bashrc
