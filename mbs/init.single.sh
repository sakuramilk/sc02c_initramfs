#!/sbin/busybox sh

/sbin/busybox mount -t ext4 /dev/block/mmcblk0p9 /mbs/mnt/system
/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /mbs/mnt/data

/sbin/busybox mkdir /system
/sbin/busybox chmod 755 /system

if [ "$1" = '1' ]; then
  # build target aosp
  /sbin/busybox sh /mbs/init.aosp.sh \
    "mount ext4 \/dev\/block\/mmcblk0p9 \/system wait ro" \
    "" \
    "\/data" \
    ""
else
  # build target samsung
  /sbin/busybox sh /mbs/init.samsung.sh \
    "mount ext4 \/dev\/block\/mmcblk0p9 \/system wait ro" \
    "" \
    "\/data" \
    ""
fi

# Set TweakGS2 properties
/sbin/busybox sh /mbs/init.tgs2.sh

/sbin/busybox umount /mbs/mnt/system
/sbin/busybox umount /mbs/mnt/data

