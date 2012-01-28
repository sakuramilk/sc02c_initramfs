#!/sbin/busybox sh

if [ "$1" = '1' ]; then
  # build target aosp  
  /sbin/busybox cp /mbs/aosp/init.rc.single /init.rc
  /sbin/busybox cp /mbs/aosp/init.smdkc210.rc /
  /sbin/busybox cp /mbs/aosp/init.smdkv310.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.smdkc210.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.smdkv310.rc /
  /sbin/busybox cp /mbs/aosp/redbend_ua /sbin/
else
  # build target samsung
  /sbin/busybox cp /mbs/samsung/init.rc.single /init.rc
  /sbin/busybox cp /mbs/samsung/init.smdkc210.rc /
  /sbin/busybox cp /mbs/samsung/ueventd.rc /
  /sbin/busybox cp /mbs/samsung/ueventd.smdkc210.rc /
  /sbin/busybox cp /mbs/samsung/redbend_ua /sbin/
  # check bootanimation
  #/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /tmp

fi

# Set TweakGS2 properties
/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /tmp
/sbin/busybox sh /mbs/init.tgs2.sh /tmp/tweakgs2.prop
/sbin/busybox mount /tmp

