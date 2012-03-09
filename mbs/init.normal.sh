#!/sbin/busybox sh

ROM_SYS_PATH=/mbs/mnt/system
ROM_DATA_PATH=/mbs/mnt/data

mount -t ext4 /dev/block/mmcblk0p9 $ROM_SYS_PATH
mount -t ext4 /dev/block/mmcblk0p10 $ROM_DATA_PATH

# android version code 9 or 10 is gingerbread, 14 or 15 is icecreamsandwitch
#SDK_VER=`grep ro\.build\.version\.sdk $ROM_SYS_PATH/build.prop | cut -d'=' -f2`
#if [ "$SDK_VER" = '14' -o "$SDK_VER" = '15' ]; then
#	ANDROID_VER=ics
#else
#	ANDROID_VER=gb
#fi

#sh /mbs/init.common.sh $ANDROID_VER

# check rom vendor
if [ -f $ROM_SYS_PATH/framework/twframework.jar ]; then
    sh /mbs/init.samsung.sh $ROM_SYS_PATH $ROM_DATA_PATH
else
    sh /mbs/init.aosp.sh $ROM_SYS_PATH $ROM_DATA_PATH
fi

# Set TweakGS2 properties
sh /mbs/init.tgs2.sh $ROM_DATA_PATH

umount $ROM_SYS_PATH
umount $ROM_DATA_PATH

