#!/system/bin/sh

mount -o remount,rw /system /system

cp /vendor/su/Superuser.apk /system/app/Superuser.apk
cp /vendor/su/su /system/bin/su

chown 0.0 /system/app/Superuser.apk
chmod 0644 /system/app/Superuser.apk

chown 0.0 /system/bin/su
chmod 4755 /system/bin/su

mount -o remount,ro /system /system
echo "install success! try su."

