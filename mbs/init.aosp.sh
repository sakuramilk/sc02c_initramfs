#!/sbin/busybox sh

# parameters
#  $1 = system partition
#  $2 = system path
#  $3 = data mount point
#  $4 = data symlink

# copy aosp rc files
/sbin/busybox cp /mbs/aosp/init.smdkc210.rc /
/sbin/busybox cp /mbs/aosp/init.smdkv310.rc /
/sbin/busybox cp /mbs/aosp/ueventd.rc /
/sbin/busybox cp /mbs/aosp/ueventd.smdkc210.rc /
/sbin/busybox cp /mbs/aosp/ueventd.smdkv310.rc /
/sbin/busybox cp /mbs/aosp/redbend_ua /sbin/

# create init.rc
/sbin/busybox sed -e "s/@MBS_SYSTEM_MOUNT/$1/g" /mbs/aosp/init.rc.sed |\
  /sbin/busybox sed -e "s/@MBS_SYSTEM_SYMLINK/$2/g" |\
  /sbin/busybox sed -e "s/@MBS_DATA_MOUNT_POINT/$3/g" |\
  /sbin/busybox sed -e "s/@MBS_DATA_SYMLINK/$4/g" > /init.rc

