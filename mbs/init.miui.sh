#!/sbin/busybox sh

# check bootanimation
if [ -f $2/local/bootanimation.zip ] || [ -f $1/media/bootanimation.zip ]; then
  BOOTANI_UID="root"
  # bootanimation wait one loop
  BOOTANIM_WAIT="setprop sys.bootanim_wait 1"
else
  BOOTANI_UID="graphics"
  BOOTANIM_WAIT=""
fi

# copy rc files
cp /mbs/miui/default.prop /
cp /mbs/miui/init.smdk4210.rc /
cp /mbs/miui/init.smdk4210.usb.rc /
cp /mbs/miui/ueventd.rc /
cp /mbs/miui/ueventd.smdk4210.rc /
cp /mbs/miui/redbend_ua /sbin/
cp /mbs/miui/lpm.rc /

# create init.rc
sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/miui/init.rc.sed | sed -e "s/@BOOTANIM_WAIT/$BOOTANIM_WAIT/g" > /init.rc
