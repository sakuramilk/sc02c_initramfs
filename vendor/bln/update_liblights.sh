#!/system/bin/sh

SRC_PATH=/vendor/bln/lights.SC-02C.so
DST_PATH=/system/lib/hw/lights.SC-02C.so

if [ ! -e $DST_PATH.orig ]; then
  mount -o remount,rw /system /system
  mv $DST_PATH $DST_PATH.orig
  cp $SRC_PATH $DST_PATH
  chown 0.0 $DST_PATH
  chmod 0644 $DST_PATH
  mount -o remount,ro /system /system
  echo "update succeed. please reboot now!"
else
  echo "already updated."
fi
