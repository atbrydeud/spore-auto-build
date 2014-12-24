#!/bin/bash

cp set_inocybe_shared_user_password.sh src/scripts
./chromite/bin/cros_sdk --create

# Don't forget ';'s after each command
./chromite/bin/cros_sdk -- /bin/bash -c "
cd ~/trunk/src/scripts/;
pwd;
./set_inocybe_shared_user_password.sh;
echo amd64-usr > .default_board;
exit;
./setup_board --force;
./build_packages;
./build_image prod --group alpha;
exit;
"

rm src/scripts/set_inocybe_shared_user_password.sh

# $1$rYphZpcg$rSjCYRMVQYHjTJTVNnwTb.
