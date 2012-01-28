#!/sbin/busybox sh

if [ "$1" = '2' ]; then
  # build target multi
  /sbin/busybox cp /mbs/recovery/recovery.rc.multi /recovery.rc
  /sbin/busybox cp /mbs/recovery/recovery.multi /sbin/recovery
  /sbin/busybox cp /mbs/recovery/recovery.fstab.multi /misc/recovery.fstab
else
  # build target samsung or aosp
  /sbin/busybox cp /mbs/recovery/recovery.rc.single /recovery.rc
  /sbin/busybox cp /mbs/recovery/recovery.single /sbin/recovery
  /sbin/busybox cp /mbs/recovery/recovery.fstab.single /misc/recovery.fstab
fi

/sbin/busybox cp /mbs/recovery/default.prop /

