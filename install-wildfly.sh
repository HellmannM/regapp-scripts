#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INSTALL_PREFIX="/opt/wildfly"
VERSION="36.0.1"
BOTH="$INSTALL_PREFIX/$VERSION"

wget https://github.com/wildfly/wildfly/releases/download/36.0.1.Final/wildfly-36.0.1.Final.tar.gz
tar -xvzf wildfly-36.0.1.Final.tar.gz
sudo mkdir -p /opt/wildfly
sudo mv wildfly-36.0.1.Final "$BOTH"
sudo ln -s "$BOTH" /opt/wildfly/latest 

sudo useradd -r -s /sbin/nologin wildfly
sudo chown -R wildfly:wildfly /opt/wildfly

# add to bashrc
echo "Adding '$BOTH' to PATH in ~/.bashrc"
echo "# wildfly" >> ~/.bashrc
echo "PATH='$BOTH/bin${PATH:+:${PATH}}'" >> ~/.bashrc

