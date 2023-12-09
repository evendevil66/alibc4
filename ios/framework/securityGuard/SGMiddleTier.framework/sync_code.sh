#!/bin/bash
set -ex

biz_id=lvm_sample
task_dir="/Users/chenkong/Code/lvm/lvm_sample"
main_dir="$task_dir/src/main"
test_dir="$task_dir/src/test"
lib_dir="$task_dir/src/lib"
script_dir="$task_dir/tool/script"

cp $main_dir/*.c .
cp $main_dir/*.h .
cp -rf $main_dir/motion/ ./motion
cp -rf $main_dir/iOS/ ./iOS
cp -rf $main_dir/android/ ./android
rm info.c
rm main.c
rm main.h

rm -rf  $task_dir/build
sh $script_dir/BuildTaskBC.sh android debug
sh $script_dir/CopyBCToAppInRootDevice.sh com.alibaba.wireless.security.middletiernative 64 uvm debug
sh $script_dir/CopyBCToAppInRootDevice.sh com.alibaba.wireless.security.middletiernative 64 lvm debug
