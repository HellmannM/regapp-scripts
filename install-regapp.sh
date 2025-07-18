#!/usr/bin/env bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## Check deps #################################################################
source "$SCRIPTS_DIR/check-dependencies.sh"

## Build RegApp ###############################################################
# clone repo
git clone https://gitlab.kit.edu/kit/reg-app/regapp.git --recursive
pushd regapp

# checkout latest tagged version
git checkout "$(git describe --tags $(git rev-list --tags --max-count=1))"

# build (needs internet connection)"
#mvn clean install -DskipTests -Dmaven.repo.local=$PWD/install
#mvn clean install -DskipTests #installs to ~/.m2
mvn clean package

# change profile if necessary with -P, e.g. `mvn -Ppord-wildfly clean package`
# Consider using a seperate build profile for your environment. You can specify
# this profile in your maven settings.xml
popd

## Setup postgres (create empty database) #####################################
sudo -u postgres createuser -P regapp-user
sudo -u postgres createdb -O regapp-user regapp
exit

