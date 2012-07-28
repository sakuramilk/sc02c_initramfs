#!/sbin/busybox sh

PROP_PATH=$1/tweakgs2.prop

USB_CONFIG=`grep persist\.sys\.usb\.config $PROP_PATH | cut -d'=' -f2`
if [ -n "$USB_CONFIG" ]; then
  echo persist.sys.usb.config=$USB_CONFIG >> /default.prop
else
  echo persist.sys.usb.config=mtp,adb >> /default.prop
fi

BOOT_SND=`grep audioflinger\.bootsnd $PROP_PATH | cut -d'=' -f2`
if [ "$BOOT_SND" = '1' ]; then
  echo audioflinger.bootsnd=1 >> /default.prop
else
  echo audioflinger.bootsnd=0 >> /default.prop
fi

CAMERA_SND=`grep ro\.camera\.sound\.forced $PROP_PATH | cut -d'=' -f2`
if [ "$CAMERA_SND" = '1' ]; then
  echo ro.camera.sound.forced=1 >> /default.prop
else
  echo ro.camera.sound.forced=0 >> /default.prop
fi

LCD_DENSITY=`grep ro\.sf\.lcd_density $PROP_PATH | cut -d'=' -f2`
if [ -z "$LCD_DENSITY" ]; then
  LCD_DENSITY=240
fi
echo ro.sf.lcd_density=$LCD_DENSITY >> /default.prop

LOGGER=`grep ro\.tgs2\.logger $PROP_PATH | cut -d'=' -f2`
if [ "$LOGGER" = '1' ]; then
  insmod /lib/modules/logger.ko
fi

CIFS=`grep ro\.tgs2\.cifs $PROP_PATH | cut -d'=' -f2`
if [ "$CIFS" = '1' ]; then
  insmod /lib/modules/cifs.ko
fi

NTFS=`grep ro\.tgs2\.ntfs $PROP_PATH | cut -d'=' -f2`
if [ "$NTFS" = '1' ]; then
  insmod /lib/modules/ntfs.ko
fi

J4FS=`grep ro\.tgs2\.j4fs $PROP_PATH | cut -d'=' -f2`
if [ "$J4FS" = '1' ]; then
  insmod /lib/modules/j4fs.ko
fi

