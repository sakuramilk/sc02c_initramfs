#!/sbin/busybox sh

# copy aosp rc files
/sbin/busybox cp /mbs/samsung/init.smdkc210.rc /
/sbin/busybox cp /mbs/samsung/ueventd.rc /
/sbin/busybox cp /mbs/samsung/ueventd.smdkc210.rc /
/sbin/busybox cp /mbs/samsung/redbend_ua /sbin/

# check bootanimation
if [ -f $2/data/local/bootanimation.zip ] || [ -f $1/media/bootanimation.zip ]; then
  BOOTANI_UID="root"
else
  BOOTANI_UID="graphics"
fi

# create init.rc
 /sbin/busybox sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/samsung/init.rc.sed > /mbs/init.rc.temp
