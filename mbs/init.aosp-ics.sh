#!/sbin/busybox sh

# copy rc files
cp /mbs/aosp-ics/default.prop /
cp /mbs/aosp-ics/init.smdk4210.rc /
cp /mbs/aosp-ics/init.smdk4210.usb.rc /
cp /mbs/aosp-ics/ueventd.rc /
cp /mbs/aosp-ics/ueventd.smdk4210.rc /
cp /mbs/aosp-ics/lpm.rc /

# create init.rc
cp /mbs/aosp-ics/init.rc /
