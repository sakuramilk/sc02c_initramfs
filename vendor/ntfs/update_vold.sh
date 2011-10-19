#!/system/bin/sh

SRC_PATH=/vendor/ntfs/vold
DST_PATH=/system/bin/vold

if [ ! -e $DST_PATH.orig ]; then
  mount -o remount,rw /system /system
  mv $DST_PATH $DST_PATH.orig
  cp $SRC_PATH $DST_PATH
  chown 0.0 $DST_PATH
  chmod 0755 $DST_PATH
  sync
  mount -o remount,ro /system /system
  echo "update succeed. please reboot now!"
else
  echo "already updated."
fi
