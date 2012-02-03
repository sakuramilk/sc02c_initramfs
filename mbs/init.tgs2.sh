#!/sbin/busybox sh

PROP_PATH=/xdata/tweakgs2.prop

BOOT_SND=`grep audioflinger\.bootsnd $PROP_PATH | cut -d'=' -f2`
if [ "$BOOT_SND" = '1' ]; then
  /sbin/busybox echo audioflinger.bootsnd=1 >> /default.prop
else
  /sbin/busybox echo audioflinger.bootsnd=0 >> /default.prop
fi

CAMERA_SND=`grep ro\.camera\.sound\.forced $PROP_PATH | cut -d'=' -f2`
if [ "$CAMERA_SND" = '1' ]; then
  /sbin/busybox echo ro.camera.sound.forced=1 >> /default.prop
else
  /sbin/busybox echo ro.camera.sound.forced=0 >> /default.prop
fi

LCD_DENSITY=`grep ro\.sf\.lcd_density $PROP_PATH | cut -d'=' -f2`
if [ -z "$LCD_DENSITY" ]; then
  LCD_DENSITY=240
fi
/sbin/busybox echo ro.sf.lcd_density=$LCD_DENSITY >> /default.prop

