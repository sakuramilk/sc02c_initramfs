#!/sbin/busybox sh

# check bootanimation
if [ -f $3/local/bootanimation.zip ] || [ -f $2/media/bootanimation.zip ]; then
  BOOTANI_UID="root"
else
  BOOTANI_UID="graphics"
fi

if [ "$1" = 'ics' ]; then
	# copy rc files
	cp /mbs/samsung/ics/init.smdk4210.rc /
	cp /mbs/samsung/ics/init.smdk4210.usb.rc /
	cp /mbs/samsung/ics/ueventd.rc /
	cp /mbs/samsung/ics/ueventd.smdk4210.rc /
	cp /mbs/samsung/ics/redbend_ua /sbin/
	# create init.rc
	sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/samsung/ics/init.rc.sed > /mbs/init.rc.temp
else
	# copy rc files
	cp /mbs/samsung/gb/init.smdkc210.rc /
	cp /mbs/samsung/gb/ueventd.rc /
	cp /mbs/samsung/gb/ueventd.smdkc210.rc /
	cp /mbs/samsung/gb/redbend_ua /sbin/
	# create init.rc
	sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/samsung/gb/init.rc.sed > /mbs/init.rc.temp
fi
