#!/bin/bash

set -e -x

CROSSDK="./chromite/bin/cros_sdk"

cp -r /var/go-agent-coreos-resources .
cp spore-auto-build/set_inocybe_shared_user_password.sh ./src/scripts
cp spore-auto-build/cr_build.sh ./src/scripts
./chromite/bin/cros_sdk --create

# Don't forget ';'s after each command
./chromite/bin/cros_sdk -- /bin/bash -c "
./cr_build.sh;
exit;
"

#run ino_core_roller_upload

rm ./src/scripts/set_inocybe_shared_user_password.sh
rm ./src/scripts/cr_build.sh
rm -rf ./go-agent-coreos-resources
