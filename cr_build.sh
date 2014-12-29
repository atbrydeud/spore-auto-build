#!/bin/bash

set -e -x

# ssh credentials
echo -e '\nAdding ssh credentials for review.inocybe.com\n'
cd ~/trunk/go-agent-coreos-resources;
cp id_rsa id_rsa.pub ~/.ssh;
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
# signing keys
echo -e '\nAdding signing keys for update_engine\n'
sudo cp update-payload-key.* /usr/share/update_engine/;
cd ~/trunk/src/scripts/;
# Install pfm-management-client
cd ~/trunk/src/third_party
git clone ssh://go-agent@review.inocybe.com:29418/pfm-management-client
cd ~/trunk/src/scripts/;
# set inocybe password
echo -e '\nSetting inocybe password for user account:inocybe\n'
./set_inocybe_shared_user_password.sh;
#build board, packages, image
echo -e '\nBuilding image\n'
echo amd64-usr > .default_board;
./setup_board --force;
./build_packages;
./build_image prod --group alpha;
#install aws
echo -e '\n Installing AWS\n'
if [ ! -d ~/trunk/src/aws-cli ]; then
    cd ~/trunk/src; mkdir aws-cli; cd aws-cli;
    wget https://bootstrap.pypa.io/get-pip.py;
    sudo python get-pip.py;
    sudo pip install awscli;
fi
cd ~/trunk/go-agent-coreos-resources;
if [ ! -d ~/.aws/ ]; then
    mkdir ~/.aws
fi
cp credentials ~/.aws/;
cd ~/trunk/src/scripts/;
# run ino_core_roller_upload

#TODO add ino_core_roller_upload
#TODO add update-client
