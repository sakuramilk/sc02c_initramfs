#!/sbin/busybox sh

#set feature_aosp
mount -t proc proc /proc
echo 1 > /proc/sys/kernel/feature_aosp
umount /proc

# copy rc files
cp /mbs/aosp/default.prop /
cp /mbs/aosp/init.smdk4210.rc /
cp /mbs/aosp/init.smdk4210.usb.rc /
cp /mbs/aosp/ueventd.rc /
cp /mbs/aosp/ueventd.smdk4210.rc /

# create init.rc
cp /mbs/aosp/init.rc.sed /mbs/init.rc.temp
