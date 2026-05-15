#!/bin/bash
# Script to build image for qemu.
# Author: Siddhant Jajoo.

git submodule init
git submodule sync
git submodule update

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"qemuarm64\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	
else
	echo "${CONFLINE} already exists in the local.conf file"
fi

RMWORKLINE="INHERIT += \"rm_work\""
cat conf/local.conf | grep "${RMWORKLINE}" > /dev/null
rmwork_info=$?

if [ $rmwork_info -ne 0 ];then
	echo "Append ${RMWORKLINE} in the local.conf file"
	echo "${RMWORKLINE}" >> conf/local.conf
	echo "RM_WORK_EXCLUDE += \"core-image-aesd aesd-assignments\"" >> conf/local.conf
else
	echo "${RMWORKLINE} already exists in the local.conf file"
fi

bitbake-layers show-layers | grep "meta-aesd" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-aesd layer"
	bitbake-layers add-layer ../meta-aesd
else
	echo "meta-aesd layer already exists"
fi

set -e
bitbake core-image-aesd
