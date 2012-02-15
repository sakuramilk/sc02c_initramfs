#!/sbin/busybox sh

#set feature_aosp
#mount -t proc proc /proc
#mount -t sysfs sysfs /sys
#echo 1 > /proc/sys/kernel/feature_aosp
#echo 1 > /sys/devices/virtual/misc/bt_lpm/bt_mode
#umount /sys
#umount /proc

# copy rc files
cp /mbs/aosp/init.smdk4210.rc /
cp /mbs/aosp/init.smdk4210.usb.rc /
cp /mbs/aosp/ueventd.rc /
cp /mbs/aosp/ueventd.smdk4210.rc /

# create init.rc
cp /mbs/aosp/init.rc.sed /mbs/init.rc.temp
