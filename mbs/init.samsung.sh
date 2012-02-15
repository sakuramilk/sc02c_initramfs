#!/sbin/busybox sh

# check bootanimation
if [ -f $2/local/bootanimation.zip ] || [ -f $1/media/bootanimation.zip ]; then
  BOOTANI_UID="root"
else
  BOOTANI_UID="graphics"
fi

# copy rc files
cp /mbs/aosp/init.smdk4210.rc /
cp /mbs/aosp/init.smdk4210.usb.rc /
cp /mbs/aosp/ueventd.rc /
cp /mbs/aosp/ueventd.smdk4210.rc /
cp /mbs/samsung/redbend_ua /sbin/

# create init.rc
sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/samsung/init.rc.sed > /mbs/init.rc.temp
