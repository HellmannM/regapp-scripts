#!/usr/bin/env bash

INSTALL_PREFIX="/opt/wildfly"
VERSION="36.0.1"

wget https://github.com/wildfly/wildfly/releases/download/36.0.1.Final/wildfly-36.0.1.Final.tar.gz
tar -xvzf wildfly-36.0.1.Final.tar.gz
sudo mkdir -p /opt/wildfly
sudo mv wildfly-36.0.1.Final "$INSTALL_PREFIX/$VERSION"
sudo ln -s "$INSTALL_PREFIX/$VERSION" /opt/wildfly/latest 

sudo useradd -r -s /sbin/nologin wildfly
sudo chown -R wildfly:wildfly /opt/wildfly

# add to bashrc
echo "Adding '$INSTALL_PREFIX/latest' to PATH in ~/.bashrc"
echo "\n# wildfly" >> ~/.bashrc
echo "PATH=\"$INSTALL_PREFIX/latest/bin\${PATH:+:\${PATH}}\"" >> ~/.bashrc

