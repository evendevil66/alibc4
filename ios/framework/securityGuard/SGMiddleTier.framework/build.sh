#
set -ex
SHELL_DIR=$(cd "$(dirname "$0")"; pwd)
platform='android'
if [ $1 == 'ios' ]; then
   platform='ios';
fi

build="debug"
if [ $2 == 'release' ]; then
   build='release';
fi

biz_id=lvm_sample
task_dir="/Users/chenkong/Code/lvm/lvm_sample"
main_dir="$task_dir/src/main"
test_dir="$task_dir/src/test"
lib_dir="$task_dir/src/lib"
script_dir="$task_dir/tool/script"


echo ">>> start update code to lvm_sm1"
cp *.c $main_dir/
cp *.h $main_dir/
cp -rf ./motion $main_dir/
cp -rf ./iOS $main_dir/
cp -rf ./android $main_dir/
rm $main_dir/BCProviderSample.h
rm $main_dir/BCProviderSample_Android.c
rm $main_dir/BCProviderSample_iOS.c

echo ">>> start bulid"
rm -rf  $task_dir/build
sh $script_dir/BuildTaskBC.sh $platform $build
if [ $platform != 'ios' ]; then
    sh $script_dir/CopyBCToAppInRootDevice.sh com.alibaba.wireless.security.middletiernative 64 lvm $build
    # sh $script_dir/CopyBCToAppInRootDevice.sh com.alibaba.wireless.security.middletiernative 64 uvm $build
    echo "finish and android already copy bc"
else
    cd $task_dir/
    rm -rf $task_dir/build/DEBUG/android
    rm -rf $task_dir/build/RELEASE/android
    zip -r build ./build 
    cd $SHELL_DIR
    sh ../../../../../scripts/update_bc_from_bcu.sh ios lvm_sample 1 2 BCProviderSample_iOS.c $task_dir/build.zip
    chmod 666 $task_dir/build.zip
    rm $task_dir/build.zip
    echo "finish and replace $build build bc to bcprovider"
fi
