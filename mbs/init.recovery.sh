#!/sbin/busybox sh

if [ "$1" = '2' ]; then
    # build target multi
    /sbin/busybox cp /mbs/recovery/recovery.multi /sbin/recovery

    # create stat dir
    mkdir /mbs/stat

    # parse mbs.conf
    mkdir -p /mbs/mnt/data
    /sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /mbs/mnt/data

    # move errmsg
    /sbin/busybox mv /mbs/mnt/data/mbs.err /mbs/stat/

    MBS_CONF=/mbs/mnt/data/mbs.conf

    if [ ! -f $MBS_CONF ]; then
        echo "mbs.boot.rom=0" > $MBS_CONF
        echo "mbs.rom0.system.part=/dev/block/mmcblk0p9" >> $MBS_CONF
        echo "mbs.rom0.data.part=/dev/block/mmcblk0p10" >> $MBS_CONF
        echo "mbs.rom0.data.path=/data0" >> $MBS_CONF
        echo "mbs.rom1.system.part=/dev/block/mmcblk0p12" >> $MBS_CONF
        echo "mbs.rom1.data.part=/dev/block/mmcblk0p10" >> $MBS_CONF
        echo "mbs.rom1.data.path=/data1" >> $MBS_CONF
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
    ROM_DATA_PATH=`grep mbs\.rom$ROM_ID\.data\.path $MBS_CONF | cut -d'=' -f2`

    /sbin/busybox umount /mbs/mnt/data

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
    PARTITION_FORMAT=ext4
    /sbin/busybox echo "/xdata		ext4		/dev/block/mmcblk0p10" >> /mbs/recovery/recovery.fstab
    if [ -z "$ROM_SYSTEM_IMG" ]; then
        MBS_MOUNT_SYSTEM=`echo $ROM_SYSTEM_PART | sed -e "s/\//\\\\\\\\\//g"`
        /sbin/busybox sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 $MBS_MOUNT_SYSTEM \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

        /sbin/busybox echo "/system		ext4		$ROM_SYSTEM_PART" >> /mbs/recovery/recovery.fstab
        /sbin/busybox echo $ROM_SYSTEM_PART > /mbs/stat/system_device
    else
        if [ "$ROM_DATA_PART" = "/dev/block/mmcblk0p10" ] || [ "$ROM_DATA_PART" = "/dev/block/mmcblk1p1" ]; then
            PARTITION_FORMAT=vfat
        fi
        mkdir -p /mbs/mnt/sys_img
        mount -t $PARTITION_FORMAT $ROM_SYSTEM_PART /mbs/mnt/sys_img
        MBS_MOUNT_SYSTEM=`echo loop@/mbs/mnt/rom$ROM_ID/sys_img$ROM_SYSTEM_IMG | sed -e "s/\//\\\\\\\\\//g"`
        /sbin/busybox sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 $MBS_MOUNT_SYSTEM \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

        /sbin/busybox echo "/system		ext4		/mbs/mnt/sys_img$ROM_SYSTEM_IMG		loop" >> /mbs/recovery/recovery.fstab
        /sbin/busybox echo /mbs/mnt/sys_img$ROM_SYSTEM_IMG > /mbs/stat/system_device
    fi

    if [ -z "$ROM_DATA_IMG" ]; then
        /sbin/busybox echo "/data_dev	ext4		$ROM_DATA_PART" >> /mbs/recovery/recovery.fstab

        mkdir -p /data_dev
        ln -s /data_dev$ROM_DATA_PATH /data
    else
        if [ "$ROM_DATA_PART" = "/dev/block/mmcblk0p10" ] || [ "$ROM_DATA_PART" = "/dev/block/mmcblk1p1" ]; then
            PARTITION_FORMAT=vfat
        fi
        mkdir -p /mbs/mnt/data_img
        mkdir -p /data_dev
        mount -t $PARTITION_FORMAT $ROM_DATA_PART /mbs/mnt/data_img
        ln -s /data_dev$ROM_DATA_PATH /data

        /sbin/busybox echo "/data_dev	ext4		/mbs/mnt/data_img$ROM_DATA_IMG		loop" >> /mbs/recovery/recovery.fstab
    fi

    #put current boot rom nuber info
    echo $ROM_ID > /mbs/stat/bootrom

else
    # build target samsung or aosp
    /sbin/busybox cp /mbs/recovery/recovery.single /sbin/recovery

    # create recovery.rc
    /sbin/busybox sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 \/dev\/block\/mmcblk0p9 \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

    # create fstab
    /sbin/busybox echo "/system		ext4		/dev/block/mmcblk0p9" >> /mbs/recovery/recovery.fstab
    /sbin/busybox echo "/data		ext4		/dev/block/mmcblk0p10" >> /mbs/recovery/recovery.fstab
fi

/sbin/busybox cp /mbs/recovery/recovery.fstab /misc/
/sbin/busybox cp /mbs/recovery/default.prop /

