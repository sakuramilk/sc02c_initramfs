#!/sbin/busybox sh

/sbin/busybox mount -t ext4 /dev/block/mmcblk0p9 /mbs/mnt/tmp_system
/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /mbs/mnt/tmp_data

if [ "$1" = '1' ]; then
  # build target aosp
  /sbin/busybox cp /mbs/aosp/init.smdkc210.rc /
  /sbin/busybox cp /mbs/aosp/init.smdkv310.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.smdkc210.rc /
  /sbin/busybox cp /mbs/aosp/ueventd.smdkv310.rc /
  /sbin/busybox cp /mbs/aosp/redbend_ua /sbin/
  /sbin/busybox cp /mbs/aosp/init.rc.single /init.rc
else
  # build target samsung
  /sbin/busybox cp /mbs/samsung/init.smdkc210.rc /
  /sbin/busybox cp /mbs/samsung/ueventd.rc /
  /sbin/busybox cp /mbs/samsung/ueventd.smdkc210.rc /
  /sbin/busybox cp /mbs/samsung/redbend_ua /sbin/
  # check bootanimation
  if [ -f /mbs/mnt/tmp_data/local/bootanimation.zip ] || [ -f /mbs/mnt/tmp_system/media/bootanimation.zip ]; then
    sed -e "s/BOOTANI_ID/root/g" /mbs/samsung/init.rc.single.sed > /init.rc
  else
    sed -e "s/BOOTANI_ID/graphics/g" /mbs/samsung/init.rc.single.sed > /init.rc
  fi
fi

# Set TweakGS2 properties
/sbin/busybox sh /mbs/init.tgs2.sh /mbs/mnt/tmp_data/tweakgs2.prop

/sbin/busybox umount /mbs/mnt/tmp_system
/sbin/busybox umount /mbs/mnt/tmp_data

