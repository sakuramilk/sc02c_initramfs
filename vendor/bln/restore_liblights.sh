#!/system/bin/sh

SRC_PATH=/system/lib/hw/lights.SC-02C.so

if [ -e $SRC_PATH.orig ]; then
  mount -o remount,rw /system /system
  rm -f $SRC_PATH
  mv $SRC_PATH.orig $SRC_PATH
  chown root.root $SRC_PATH
  chmod 0644 $SRC_PATH
  mount -o remount,ro /system /system
  echo "restore success. please reboot now!"
else
  echo "restore failed. not found $SRC_PATH.org"
fi
