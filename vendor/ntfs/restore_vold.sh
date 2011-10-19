#!/system/bin/sh

SRC_PATH=/system/bin/vold

if [ -e $SRC_PATH.orig ]; then
  mount -o remount,rw /system /system
  rm -f $SRC_PATH
  mv $SRC_PATH.orig $SRC_PATH
  chown 0.0 $SRC_PATH
  chmod 0755 $SRC_PATH
  sync
  mount -o remount,ro /system /system
  echo "restore success. please reboot now!"
else
  echo "restore failed. not found $SRC_PATH.org"
fi
