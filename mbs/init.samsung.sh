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
cp /mbs/samsung/init.smdkc210.rc /
cp /mbs/samsung/ueventd.rc /
cp /mbs/samsung/ueventd.smdkc210.rc /
cp /mbs/samsung/redbend_ua /sbin/

# create init.rc
sed -e "s/@BOOTANI_UID/$BOOTANI_UID/g" /mbs/samsung/init.rc.sed | sed -e "s/@BOOTANIM_WAIT/$BOOTANIM_WAIT/g" > /init.rc
