#!/sbin/busybox sh



#set feature_aosp
/sbin/busybox mount -t proc proc /proc
/sbin/busybox mount -t sysfs sysfs /sys
echo 1 > /proc/sys/kernel/feature_aosp
echo 1 > /sys/devices/virtual/misc/bt_lpm/bt_mode
/sbin/busybox umount /sys
/sbin/busybox umount /proc

# copy aosp rc files
/sbin/busybox cp /mbs/aosp/init.smdkc210.rc /
/sbin/busybox cp /mbs/aosp/init.smdkv310.rc /
/sbin/busybox cp /mbs/aosp/ueventd.rc /
/sbin/busybox cp /mbs/aosp/ueventd.smdkc210.rc /
/sbin/busybox cp /mbs/aosp/ueventd.smdkv310.rc /
/sbin/busybox cp /mbs/aosp/redbend_ua /sbin/

# create init.rc
/sbin/busybox cp /mbs/aosp/init.rc.sed /mbs/init.rc.temp
	
