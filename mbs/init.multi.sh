#!/sbin/busybox sh

/sbin/busybox mount -t ext4 /dev/block/mmcblk0p9 /mbs/mnt/system
/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /mbs/mnt/data

# parse mbs.conf
MBS_CONF=/mbs/mnt/tmp_data/mbs.conf

ret=`grep mbs\.boot\.rom $MBS_CONF | cut -d'=' -f2`
if [ -e "$ret" ]; then
  ROM_ID=0
else
  ROM_ID=$ret
fi

ROM_SYSTEM_PART=`grep mbs\.rom$ROM_ID\.system\.part $MBS_CONF | cut -d'=' -f2`
ROM_SYSTEM_IMG=`grep mbs\.rom$ROM_ID\.system\.img $MBS_CONF | cut -d'=' -f2`
ROM_SYSTEM_PATH=`grep mbs\.rom$ROM_ID\.system\.path $MBS_CONF | cut -d'=' -f2`
ROM_DATA_PART=`grep mbs\.rom$ROM_ID\.data\.part $MBS_CONF | cut -d'=' -f2`
ROM_DATA_IMG=`grep mbs\.rom$ROM_ID\.data\.img $MBS_CONF | cut -d'=' -f2`
ROM_DATA_PATH=`grep mbs\.rom$ROM_ID\.data\.path $MBS_CONF | cut -d'=' -f2`

# error check
if [ -e "$ROM_SYSTEM_PART" ]; then
  ROM_SYSTEM_PART="\/dev\/block\/mmcblk0p9"
  ROM_SYSTEM_IMG=""
  ROM_SYSTEM_PATH=""
fi
if [ -e "$ROM_DATA_PART" ]; then
  ROM_DATA_PART="\/dev\/block\/mmcblk0p9"
  ROM_DATA_IMG=""
  ROM_DATA_PATH=""
fi

# check rom target
if [ -f /mbs/mnt/system/framework/twframework.jar ]; then
  # rom target samsung
  /sbin/busybox sh /mbs/init.samsung.sh \
    "mount ext4 \/dev\/block\/mmcblk0p9 \/system wait ro" \
    "" \
    "\/data" \
    ""
else
  # rom target aosp
  /sbin/busybox sh /mbs/init.aosp.sh \
    "mount ext4 \/dev\/block\/mmcblk0p9 \/system wait ro" \
    "" \
    "\/data" \
    ""
fi

# init share
/sbin/busybox sh /mbs/init.share.sh

# Set TweakGS2 properties
/sbin/busybox sh /mbs/init.tgs2.sh

/sbin/busybox umount /mbs/mnt/system
/sbin/busybox umount /mbs/mnt/data

