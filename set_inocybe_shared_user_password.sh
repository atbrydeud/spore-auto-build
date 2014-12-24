#!/bin/bash

# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Script to set the password for the shared user account. Stores the MD5crypt'd
# password to a file inside chroot, for use by build_image.

# Make sure common.sh is here.
SCRIPT_ROOT=$(dirname $(readlink -f "$0"))
. "${SCRIPT_ROOT}/common.sh" || { echo "Unable to load common.sh"; exit 1; }

assert_inside_chroot

# Die on any errors.
switch_to_strict_mode

SHARED_USER_PASSWD_FILE="/etc/shared_user_passwd.txt"

PASSWORD="inocybe"

CRYPTED_PASSWD="$(echo "$PASSWORD" | openssl passwd -1 -stdin)"
PASSWORD="gone now"

echo "${CRYPTED_PASSWD}" | sudo_clobber "${SHARED_USER_PASSWD_FILE}"
echo "Password set in ${SHARED_USER_PASSWD_FILE}"
