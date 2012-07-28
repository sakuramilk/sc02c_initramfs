#!/sbin/busybox sh

# copy rc files
cp /mbs/aosp-jb/default.prop /
cp /mbs/aosp-jb/init.smdk4210.rc /
cp /mbs/aosp-jb/init.smdk4210.usb.rc /
cp /mbs/aosp-jb/init.trace.rc /
cp /mbs/aosp-jb/init.usb.rc /
cp /mbs/aosp-jb/ueventd.rc /
cp /mbs/aosp-jb/ueventd.smdk4210.rc /
cp /mbs/aosp-jb/lpm.rc /

# copy bin files
cp /mbs/aosp-jb/adbd /sbin/

# create init.rc
cp /mbs/aosp-jb/init.rc /
