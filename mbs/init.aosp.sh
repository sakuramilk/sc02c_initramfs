#!/sbin/busybox sh

if [ "$1" = 'ics' ]; then
	# copy rc files
	cp /mbs/aosp/ics/init.smdk4210.rc /
	cp /mbs/aosp/ics/init.smdk4210.usb.rc /
	cp /mbs/aosp/ics/ueventd.rc /
	cp /mbs/aosp/ics/ueventd.smdk4210.rc /
	cp /mbs/aosp/ics/redbend_ua /sbin/
else
	#set feature_aosp
	mount -t proc proc /proc
	mount -t sysfs sysfs /sys
	echo 1 > /proc/sys/kernel/feature_aosp
	echo 1 > /sys/devices/virtual/misc/bt_lpm/bt_mode
	umount /sys
	umount /proc
	# copy rc files
	cp /mbs/aosp/gb/init.smdkc210.rc /
	cp /mbs/aosp/gb/init.smdkv310.rc /
	cp /mbs/aosp/gb/ueventd.rc /
	cp /mbs/aosp/gb/ueventd.smdkc210.rc /
	cp /mbs/aosp/gb/ueventd.smdkv310.rc /
	cp /mbs/aosp/gb/redbend_ua /sbin/
	# create init.rc
	cp /mbs/aosp/gb/init.rc.sed /mbs/init.rc.temp
fi
