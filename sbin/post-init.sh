#!/sbin/busybox sh

# Android Logger enable tweak
if /sbin/busybox [ "`/sbin/busybox grep ANDROIDLOGGER /data/local/tweakgs2.conf`" ]; then
  insmod /lib/modules/logger.ko
fi

# Enable CIFS tweak
if /sbin/busybox [ "`grep CIFS /data/local/tweakgs2.conf`" ]; then
  insmod /lib/modules/cifs.ko
fi

