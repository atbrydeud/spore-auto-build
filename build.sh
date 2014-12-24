#!/bin/bash

set -e -x

CROSSDK="./chromite/bin/cros_sdk"

cp -r /var/go-agent-coreos-resources .
cp spore-auto-build/set_inocybe_shared_user_password.sh ./src/scripts
./chromite/bin/cros_sdk --create

# Don't forget ';'s after each command
./chromite/bin/cros_sdk -- /bin/bash -c "
mkdir ~/.ssh;
cd ~/trunk/go-agent-coreos-resources;
cp id_rsa id_rsa.pub ~/.ssh;
cp update-payload-key.* /usr/share/update-engine;
cd ~/trunk/src/scripts/;
pwd;
./set_inocybe_shared_user_password.sh;
echo amd64-usr > .default_board;
# ./setup_board --force;
# ./build_packages;
# ./build_image prod --group alpha;
#install awscli for use of ino_core_roller_upload
cd ~/trunk/src; mkdir aws-cli; cd aws-cli;
wget https://bootstrap.pypa.io/get-pip.py;
sudo python get-pip.py;
sudo pip install awscli;
cd ~/trunk/go-agent-coreos-resources;
mkdir ~/.aws
cp credentials ~/.aws/;
#run ino_core_roller_upload
cd ~/trunk/src/scripts/;
exit;
"

rm ./src/scripts/set_inocybe_shared_user_password.sh
