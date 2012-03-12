#!/sbin/busybox sh

#------------------------------------------------------
#foce ROM0 boot setting
#   $1 xxxx.part value
#   $2 xxxx.img value
#------------------------------------------------------
func_make_conf()
{
    echo "mbs.boot.rom=0" > $MBS_CONF
    echo "mbs.rom0.system.part=$DEV_BLOCK_FACTORYFS" >> $MBS_CONF
    echo "mbs.rom0.data.part=$DEV_BLOCK_DATA" >> $MBS_CONF
    echo "mbs.rom0.data.path=/data0" >> $MBS_CONF
    echo "mbs.rom1.system.part=/$DEV_BLOCK_HIDDEN" >> $MBS_CONF
    echo "mbs.rom1.data.part=$DEV_BLOCK_DATA" >> $MBS_CONF
    echo "mbs.rom1.data.path=/data1" >> $MBS_CONF
}
#------------------------------------------------------
#foce ROM0 boot setting
#	$1: error msg
#------------------------------------------------------
func_error()
{
	mv $MBS_CONF $MBS_CONF.old
	func_make_conf
}
#------------------------------------------------------
# check patation
#   $1 xxxx.part value
#   $2 xxxx.img value
#------------------------------------------------------
func_check_part()
{
	case $1 in
		"$DEV_BLOCK_ZIMAGE"    )    return 0 ;;
		"$DEV_BLOCK_FACTORYFS" )    return 0 ;;
		"$DEV_BLOCK_DATA"      )    return 0 ;;
		"$DEV_BLOCK_HIDDEN"    )    return 0 ;;
		"$DEV_BLOCK_EMMC2"     )    return 0 ;;
		"$DEV_BLOCK_EMMC3"     )    return 0 ;;
		"$DEV_BLOCK_SDCARD"    )    echo "vfat part" ;;
		"$DEV_BLOCK_EMMC1"     )    echo "vfat part" ;;
	    *)       func_error "$1 is invalid part" ;;
	esac

	if [ -z $2 ]; then
		func_error  "no img detect!"
	fi
	#echo "part is OK"
	return 0
}

if [ "$1" = '2' ]; then
    # build target multi
    cp /mbs/recovery/recovery.multi /sbin/recovery

    # create stat dir
    mkdir /mbs/stat

    # parse mbs.conf
    mkdir -p /mbs/mnt/data
    mount -t ext4 $DEV_BLOCK_DATA /mbs/mnt/data

    # move errmsg
    mv /mbs/mnt/data/mbs.err /mbs/stat/

    if [ ! -s $MBS_CONF ]; then
        func_make_conf
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

    umount /mbs/mnt/data

	func_check_part $ROM_SYSTEM_PART $ROM_SYSTEM_IMG
	func_check_part $ROM_DATA_PART $ROM_DATA_IMG

    # check error
    if [ -z "$ROM_SYSTEM_PART" ]; then
        ROM_SYSTEM_PART="$DEV_BLOCK_FACTORYFS"
        ROM_SYSTEM_IMG=""
    fi
    if [ -z "$ROM_DATA_PART" ]; then
        ROM_DATA_PART="$DEV_BLOCK_DATA"
        ROM_DATA_IMG=""
    fi

    # create fstab
    PARTITION_FORMAT=ext4
    echo "/xdata		ext4		$DEV_BLOCK_DATA" >> /mbs/recovery/recovery.fstab
    if [ -z "$ROM_SYSTEM_IMG" ]; then
        MBS_MOUNT_SYSTEM=`echo $ROM_SYSTEM_PART | sed -e "s/\//\\\\\\\\\//g"`
        sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 $MBS_MOUNT_SYSTEM \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

        echo "/system		ext4		$ROM_SYSTEM_PART" >> /mbs/recovery/recovery.fstab
        echo $ROM_SYSTEM_PART > /mbs/stat/system_device
    else
        if [ "$ROM_SYSTEM_PART" = "$DEV_BLOCK_SDCARD" ] || [ "$ROM_SYSTEM_PART" = "$DEV_BLOCK_EMMC1" ]; then
            PARTITION_FORMAT=vfat
        fi
        mkdir -p /mbs/mnt/sys_img
        mount -t $PARTITION_FORMAT $ROM_SYSTEM_PART /mbs/mnt/sys_img
        MBS_MOUNT_SYSTEM=`echo loop@/mbs/mnt/rom$ROM_ID/sys_img$ROM_SYSTEM_IMG | sed -e "s/\//\\\\\\\\\//g"`
        sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 $MBS_MOUNT_SYSTEM \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

        echo "/system		ext4		/mbs/mnt/sys_img$ROM_SYSTEM_IMG		loop" >> /mbs/recovery/recovery.fstab
        echo /mbs/mnt/sys_img$ROM_SYSTEM_IMG > /mbs/stat/system_device
    fi

    if [ -z "$ROM_DATA_IMG" ]; then
        echo "/data_dev	ext4		$ROM_DATA_PART" >> /mbs/recovery/recovery.fstab

        mkdir -p /data_dev
        ln -s /data_dev$ROM_DATA_PATH /data
    else
        if [ "$ROM_DATA_PART" = "$DEV_BLOCK_SDCARD" ] || [ "$ROM_DATA_PART" = "$DEV_BLOCK_EMMC1" ]; then
            PARTITION_FORMAT=vfat
        fi
        mkdir -p /mbs/mnt/data_img
        mkdir -p /data_dev
        mount -t $PARTITION_FORMAT $ROM_DATA_PART /mbs/mnt/data_img
        ln -s /data_dev$ROM_DATA_PATH /data

        echo "/data_dev	ext4		/mbs/mnt/data_img$ROM_DATA_IMG		loop" >> /mbs/recovery/recovery.fstab
    fi

    #put current boot rom nuber info
    echo $ROM_ID > /mbs/stat/bootrom

else
    # build target samsung or aosp
    cp /mbs/recovery/recovery.single /sbin/recovery

    # create recovery.rc
    sed -e "s/@MBS_MOUNT_SYSTEM/mount ext4 \/dev\/block\/mmcblk0p9 \/system wait rw/g" /mbs/recovery/recovery.rc.sed > /recovery.rc

    # create fstab
    echo "/system		ext4		$DEV_BLOCK_FACTORYFS" >> /mbs/recovery/recovery.fstab
    echo "/data		ext4		$DEV_BLOCK_DATA" >> /mbs/recovery/recovery.fstab
fi

cp /mbs/recovery/recovery.fstab /misc/
cp /mbs/recovery/default.prop /

