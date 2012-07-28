#!/sbin/busybox sh

ROM_SYS_PATH=/mbs/mnt/system
ROM_DATA_PATH=/mbs/mnt/data

mount -t ext4 /dev/block/mmcblk0p9 $ROM_SYS_PATH
mount -t ext4 /dev/block/mmcblk0p10 $ROM_DATA_PATH

# check rom vendor
if [ -f $ROM_SYS_PATH/framework/twframework.jar ]; then
    if [ -f $ROM_SYS_PATH/framework/framework-miui.jar ]; then
        sh /mbs/init.miui.sh $ROM_SYS_PATH $ROM_DATA_PATH
    else
        sh /mbs/init.samsung.sh $ROM_SYS_PATH $ROM_DATA_PATH
    fi
else
    SDK_VER=`grep ro\.build\.version\.sdk $ROM_SYS_PATH/build.prop | cut -d'=' -f2`
    if [ "$SDK_VER" = '16' ]; then
        sh /mbs/init.aosp-jb.sh $ROM_SYS_PATH $ROM_DATA_PATH
    else
        sh /mbs/init.aosp-ics.sh $ROM_SYS_PATH $ROM_DATA_PATH
    fi
fi

# Set TweakGS2 properties
sh /mbs/init.tgs2.sh $ROM_DATA_PATH

umount $ROM_SYS_PATH
umount $ROM_DATA_PATH

