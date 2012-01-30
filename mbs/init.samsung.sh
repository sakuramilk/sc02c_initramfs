#!/sbin/busybox sh

# parameters
#  $1 = system partition
#  $2 = system path
#  $3 = data mount point
#  $4 = data symlink

# copy aosp rc files
/sbin/busybox cp /mbs/samsung/init.smdkc210.rc /
/sbin/busybox cp /mbs/samsung/ueventd.rc /
/sbin/busybox cp /mbs/samsung/ueventd.smdkc210.rc /
/sbin/busybox cp /mbs/samsung/redbend_ua /sbin/

# check bootanimation
if [ -f /mbs/mnt/data/local/bootanimation.zip ] || [ -f /mbs/mnt/system/media/bootanimation.zip ]; then
  BOOTANI_UID="root"
else
  BOOTANI_UID="graphics"
fi

# create init.rc
/sbin/busybox sed -e "s/@MBS_SYSTEM_MOUNT/$1/g" /mbs/samsung/init.rc.sed |\
  /sbin/busybox sed -e "s/@MBS_SYSTEM_SYMLINK/$2/g" |\
  /sbin/busybox sed -e "s/@MBS_DATA_MOUNT_POINT/$3/g" |\
  /sbin/busybox sed -e "s/@MBS_DATA_SYMLINK/$4/g" |\
  /sbin/busybox sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" > /init.rc
