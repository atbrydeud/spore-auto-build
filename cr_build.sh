#!/bin/bash

set -e -x

# ssh credentials
echo -e '\nAdding ssh credentials for review.inocybe.com\n'
cd ~/trunk/go-agent-coreos-resources;
cp id_rsa id_rsa.pub ~/.ssh;
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# signing keys
# echo -e '\nAdding signing keys for update_engine\n'
# sudo cp update-payload-key.* /usr/share/update_engine/;
# cd ~/trunk/src/scripts/;

# Install pfm-management-client and replace updateservicectl
cd ~/trunk/src/third_party
rm -rf ~/trunk/src/third_party/pfm-management-client
git clone ssh://go-agent@review.inocybe.com:29418/pfm-management-client
cd pfm-management-client
./build
sudo rm /usr/bin/updateservicectl
sudo cp bin/updateservicectl /usr/bin/updateservicectl
rm -rf ~/trunk/src/third_party/pfm-management-client

# Get NOS-update-client and place it at ~/trunk/src/coreos
rm -rf ~/trunk/src/third_party/NOS-update-client
cd ~/trunk/src/third_party
git clone ssh://go-agent@review.inocybe.com:29418/NOS-update-client
cd NOS-update-client
./build

rm -rf ~/trunk/src/third_party/coreos-overlay/app-misc/NOS-update-client/
mkdir ~/trunk/src/third_party/coreos-overlay/app-misc/NOS-update-client/
cp -r ebuild/* ~/trunk/src/third_party/coreos-overlay/app-misc/NOS-update-client/
rm -rf ~/trunk/src/third_party/NOS-update-client

# set inocybe password
cd ~/trunk/src/scripts/;
echo -e '\nSetting inocybe password for user account:inocybe\n'
./set_inocybe_shared_user_password.sh;

#build board, packages, image
cd ~/trunk/src/scripts/;
echo -e '\nBuilding image\n'
echo amd64-usr > .default_board;
./setup_board --force;
./build_packages;
./build_image prod --group alpha;

#install aws
echo -e '\n Installing AWS\n'
rm -rf ~/trunk/src/aws-cli
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
# Needs update server running
rm -rf ~/trunk/update_build.txt
export UPDATECTL_SERVER="http://172.19.0.7:8080"
./ino_core_roller_upload --image_dir ~/trunk/src/build/images/amd64-usr/latest/
mv update_build.txt ~/trunk/

# Necessary for version number
export SCRIPT_ROOT=~/trunk/src/scripts
export GCLIENT_ROOT=$(readlink -f "${SCRIPT_ROOT}/../../")
. "${SCRIPT_ROOT}/common.sh" || exit 1

# upload latest image to s3
echo -e '\nUploading Image to AWS S3\n'
LATEST_IMAGE_DIR=~/trunk/src/build/images/amd64-usr/latest/
cd $LATEST_IMAGE_DIR
VERSION_STRING=`echo $COREOS_VERSION_STRING | sed -r 's/[\+]/-/g'`
S3_BUCKET="spore.images"
S3_URL="s3://${S3_BUCKET}/${VERSION_STRING}/coreos-${VERSION_STRING}.vmdk"
HTTP_URL="http://${S3_BUCKET}.s3.amazonaws.com/${VERSION_STRING}/coreos-${VERSION_STRING}.vmdk"
qemu-img convert -f raw -O vmdk coreos_production_image.bin coreos.vmdk
aws s3 cp ~/trunk/src/build/images/amd64-usr/latest/coreos.vmdk ${S3_URL}

# Create file for latest build version number and link
echo -e '\nSaving s3 url and version number\n'
cd ~/trunk
rm -rf build.txt
echo ${COREOS_VERSION_STRING} > build.txt
echo ${HTTP_URL} >> build.txt



#TODO add ino_core_roller_upload
