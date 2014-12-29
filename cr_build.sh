#!/bin/bash

set -e -x

# ssh credentials
cd ~/trunk/go-agent-coreos-resources;
cp id_rsa id_rsa.pub ~/.ssh;
# signing keys
sudo cp update-payload-key.* /usr/share/update_engine/;
cd ~/trunk/src/scripts/;
# set inocybe password
./set_inocybe_shared_user_password.sh;
#build board, packages, image
echo amd64-usr > .default_board;
./setup_board --force;
./build_packages;
./build_image prod --group alpha;
#install aws
cd ~/trunk/src; mkdir aws-cli; cd aws-cli;
wget https://bootstrap.pypa.io/get-pip.py;
sudo python get-pip.py;
sudo pip install awscli;
cd ~/trunk/go-agent-coreos-resources;
if [ ! -d ~/.aws/ ]; then
    mkdir ~/.aws
fi
cp credentials ~/.aws/;
cd ~/trunk/src/scripts/;
# run ino_core_roller_upload

#TODO add ino_core_roller_upload
#TODO add update-client
#TODO add our pfm-management-client
