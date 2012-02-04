#!/sbin/busybox sh

if [ "$1" = '2' ]; then
  # build target multi
  /sbin/busybox cp /mbs/recovery/recovery.multi /sbin/recovery

  # parse mbs.conf
  /sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /mbs/mnt/tmp_data
  MBS_CONF=/mbs/mnt/tmp_data/mbs.conf

  if [ ! -f $MBS_CONF ]; then
    echo "mbs.boot.rom=0" > $MBS_CONF
    echo "mbs.rom0.system.part=/dev/block/mmcblk0p9" >> $MBS_CONF
  fi

  ret=`grep mbs\.boot\.rom $MBS_CONF | cut -d'=' -f2`
  if [ -z "$ret" ]; then
    ROM_ID=0
  else
    ROM_ID=$ret
  fi

  ROM_SYSTEM_PART=`grep mbs\.rom$ROM_ID\.system\.part $MBS_CONF | cut -d'=' -f2`
  ROM_SYSTEM_IMG=`grep mbs\.rom$ROM_ID\.system\.img $MBS_CONF | cut -d'=' -f2`
  ROM_DATA_PART=`grep mbs\.rom$ROM_ID\.data\.part $MBS_CONF | cut -d'=' -f2`
  ROM_DATA_IMG=`grep mbs\.rom$ROM_ID\.data\.img $MBS_CONF | cut -d'=' -f2`

  # check error
  if [ -z "$ROM_SYSTEM_PART" ]; then
    ROM_SYSTEM_PART="/dev/block/mmcblk0p9"
    ROM_SYSTEM_IMG=""
  fi
  if [ -z "$ROM_DATA_PART" ]; then
    ROM_DATA_PART="/dev/block/mmcblk0p10"
    ROM_DATA_IMG=""
  fi

  # create fstab
  /sbin/busybox echo "/xdata		ext4		/dev/block/mmcblk0p10" >> /mbs/recovery/recovery.fstab
  if [ -z "$ROM_SYSTEM_IMG" ]; then
    /sbin/busybox echo "/system		ext4		$ROM_SYSTEM_PART" >> /mbs/recovery/recovery.fstab
  else
    /sbin/busybox echo "/system		ext4		$ROM_SYSTEM_IMG		loop" >> /mbs/recovery/recovery.fstab
  fi
  if [ -z "$ROM_DATA_IMG" ]; then
    /sbin/busybox echo "/data		ext4		$ROM_DATA_PART" >> /mbs/recovery/recovery.fstab
  else
    /sbin/busybox echo "/data		ext4		$ROM_DATA_IMG		loop" >> /mbs/recovery/recovery.fstab
  fi

  # write rom id
  /sbin/busybox echo $ROM_ID > /misc/boot_rom_id

else
  # build target samsung or aosp
  /sbin/busybox cp /mbs/recovery/recovery.single /sbin/recovery

  # create fstab
  /sbin/busybox echo "/system		ext4		/dev/block/mmcblk0p9" >> /mbs/recovery/recovery.fstab
  /sbin/busybox echo "/data		ext4		/dev/block/mmcblk0p10" >> /mbs/recovery/recovery.fstab
fi

/sbin/busybox cp /mbs/recovery/recovery.rc /
/sbin/busybox cp /mbs/recovery/recovery.fstab /misc/
/sbin/busybox cp /mbs/recovery/default.prop /

