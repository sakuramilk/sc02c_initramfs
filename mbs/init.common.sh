#!/sbin/busybox sh

#set config
BUILD_TARGET=$1

if [ "$BUILD_TARGET" = '2' ]; then
	MBS_CONF="/xdata/mbs.conf"
	LOOP_CNT="0 1 2 3 4 5 6 7"
else
	#todo skip making mbs info by fixed value
	MBS_CONF="/mbs/single.conf"
	LOOP_CNT="0"
fi

export MBS_LOG=/xdata/mbs4.log
#------------------------------------------------------
#init mbs dev mnt point
#------------------------------------------------------
func_mbs_mount_init()
{
	#/system is synbolic link when multi boot.
	rmdir /system

	#make mbs dev mnt point
	chmod 755 /mbs/mnt
	for i in $LOOP_CNT; do
		mkdir /mbs/mnt/rom${i}
		mkdir /mbs/mnt/rom${i}/data_dev
		mkdir /mbs/mnt/rom${i}/data_img
		mkdir /mbs/mnt/rom${i}/sys_dev
		mkdir /mbs/mnt/rom${i}/sys_img

		chmod 755 /mbs/mnt/rom${i}
		chmod 755 /mbs/mnt/rom${i}/data_dev
		chmod 755 /mbs/mnt/rom${i}/data_img
		chmod 755 /mbs/mnt/rom${i}/sys_dev
		chmod 755 /mbs/mnt/rom${i}/sys_img
	done
}
#------------------------------------------------------
#foce ROM0 boot setting
#------------------------------------------------------
func_mbs_foce_pramary()
{
	export ROM_ID=0
	export ROM_DATA_PART_0=/dev/block/mmcblk0p10
	export ROM_DATA_IMG_0=""
	#wraning last "/" is not need
	export ROM_DATA_PATH_0=/mbs/mnt/rom0/data_dev/data0
	#export ROM_DATA_PATH_0=/mbs/mnt/rom0/data_dev

	export ROM_SYS_PART=/dev/block/mmcblk0p9
	export ROM_SYS_IMG=""
	#wraning last "/" is not need
	export ROM_SYS_PATH=/mbs/mnt/rom0/sys_dev
}

#------------------------------------------------------
#create loopback device
#    arg_mnt_base
#    arg_img_part: partation
#    arg_img_path:$ROM_DATA_IMG
#    arg_mnt_img: data_img / sys_img
#    arg_mnt_loop: data_loop / sys_loop
#    arg_dev_id; 20${id} /10${id}
#------------------------------------------------------
func_mbs_create_loop_dev()
{
    arg_mnt_base=$1
    arg_img_part=$2
    arg_img_path=$3
    arg_mnt_img=$4
    arg_mnt_loop=$5
    arg_dev_id=$6

	#echo ROM_DATA_IMG :$img_path >> $MBS_LOG	
	#mount img part device
	mnt_img=$arg_mnt_base/$arg_mnt_img
	img_path=$mnt_img$arg_img_path
	dev_loop=$arg_mnt_base/$arg_mnt_loop
	
	/sbin/busybox mount -t ext4 $arg_img_part $mnt_img

	echo mnt_img=$mnt_img >> $MBS_LOG
	echo img_path=$img_path >> $MBS_LOG
	echo dev_loop=$dev_loop >> $MBS_LOG

	# set loopback devce
	if [ -f $img_path ]; then
		echo create loop: $dev_loop >> $MBS_LOG
		/sbin/busybox mknod $dev_loop b 7 ${arg_dev_id}
		/sbin/busybox losetup $dev_loop $img_path
		RET=$dev_loop
	else
		export RET=""	
		#echo rom${id} image is not exist >> $MBS_LOG
	fi
}

#==============================================================================
# main process
#==============================================================================
/sbin/busybox mount -t ext4 /dev/block/mmcblk0p10 /xdata

BOOT_DATE=`date`
echo "boot start : $BOOT_DATE" > $MBS_LOG

#/system is synbolic link when multi boot.
func_mbs_mount_init

#get mbs.conf 
if [ ! -f $MBS_CONF ]; then
	func_mbs_foce_pramary
	echo "$MBS_CONF is not exist. booting rom0..." >> $MBS_LOG
else
	# get boot rom number
	ret=`grep mbs\.boot\.rom $MBS_CONF | cut -d'=' -f2`
	if [ -e "$ret" ]; then
	  ROM_ID=0
	else
	  ROM_ID=$ret
	fi
	echo "ROM_ID : $ROM_ID" >> $MBS_LOG

	echo "start of for" >> $MBS_LOG
	for i in $LOOP_CNT; do
		echo "for:$i" >> $MBS_LOG
		# romX setting
		ROM_DATA_PART=`grep mbs\.rom$i\.data\.part $MBS_CONF | cut -d'=' -f2`
		ROM_DATA_IMG=`grep mbs\.rom$i\.data\.img $MBS_CONF | cut -d'=' -f2`
		ROM_DATA_PATH=`grep mbs\.rom$i\.data\.path $MBS_CONF | cut -d'=' -f2`

		mnt_base=/mbs/mnt/rom${i}
		mnt_dir=$mnt_base/data_dev

		if [ ! -z "$ROM_DATA_IMG" ]; then
			func_mbs_create_loop_dev $mnt_base $ROM_DATA_PART $ROM_DATA_IMG data_img data_loop 20${i}
			ROM_DATA_PART=$RET
			if [ -z "$ROM_DATA_PART" ]; then
				echo rom${i} image is not exist >> $MBS_LOG
			fi
		fi
		ROM_DATA_PATH=$mnt_dir$ROM_DATA_PATH
		ROM_DATA_PATH=`echo $ROM_DATA_PATH | sed -e "s/\/$//g"`

		eval export ROM_DATA_PART_$i=$ROM_DATA_PART
		eval export ROM_DATA_IMG_$i=$ROM_DATA_IMG
		eval export ROM_DATA_PATH_$i=$ROM_DATA_PATH

		#for Debug
		eval echo mbs.rom${i}.data.part=$"ROM_DATA_PART_"$i >> $MBS_LOG
		eval echo mbs.rom${i}.data.img=$"ROM_DATA_IMG_"$i >> $MBS_LOG
		eval echo mbs.rom${i}.data.path=$"ROM_DATA_PATH_"$i >> $MBS_LOG
	done

	echo "end of for" >> $MBS_LOG

	#----------------------------
	# set system
	#----------------------------
	#check data valid
	eval ROM_DATA_PART=$"ROM_DATA_PART_"$ROM_ID
	if [ -z "$ROM_DATA_PART" ]; then
		echo rom${ROM_ID} data is invalid:foce rom0 boot >> $MBS_LOG
		ROM_ID=0
	fi

	export ROM_SYS_PART=`grep mbs\.rom$ROM_ID\.system\.part $MBS_CONF | cut -d'=' -f2`
	export ROM_SYS_IMG=`grep mbs\.rom$ROM_ID\.system\.img $MBS_CONF | cut -d'=' -f2`
	export ROM_SYS_PATH=`grep mbs\.rom$ROM_ID\.system\.path $MBS_CONF | cut -d'=' -f2`

	mnt_base=/mbs/mnt/rom${ROM_ID}
	mnt_dir=$mnt_base/sys_dev
	if [ ! -z "$ROM_SYS_IMG" ]; then
		echo ROM_SYS_IMG :$ROM_SYS_IMG >> $MBS_LOG	

		func_mbs_create_loop_dev $mnt_base $ROM_SYS_PART $ROM_SYS_IMG sys_img sys_loop 10${ROM_ID}
		ROM_SYS_PART=$RET
	fi

	if [ -z "$ROM_SYS_PART" ]; then
		echo rom${ROM_ID} sys is invalid:foce rom0 boot >> $MBS_LOG			
		func_mbs_foce_pramary
	else
		#ROM_SYS_PATH=/mbs_sys$ROM_SYS_PATH
		ROM_SYS_PATH=$mnt_dir$ROM_SYS_PATH
		ROM_SYS_PATH=`echo $ROM_SYS_PATH | sed -e "s/\/$//g"`
	fi		
	#for Debug
	echo ROM_SYS_PART=$ROM_SYS_PART >> $MBS_LOG
	echo ROM_SYS_IMG=$ROM_SYS_IMG >> $MBS_LOG
	echo ROM_SYS_PART=$ROM_SYS_PATH >> $MBS_LOG
fi


#============================================================
# check rom vendor
#============================================================
mnt_base=/mbs/mnt/rom${ROM_ID}
mnt_dir=$mnt_base/sys_dev
mnt_data=$mnt_base/data_dev

eval export BOOT_ROM_DATA_PATH=$"ROM_DATA_PATH_"${ROM_ID}

/sbin/busybox mount -t ext4 $ROM_SYS_PART $mnt_dir
/sbin/busybox mount -t ext4 $ROM_SYS_PART $mnt_data

if [ -f $ROM_SYS_PATH/framework/twframework.jar ]; then
	ROM_VENDOR=samsung
	/sbin/busybox sh /mbs/init.samsung.sh $ROM_SYS_PATH $BOOT_ROM_DATA_PATH 
else
	/sbin/busybox sh /mbs/init.aosp.sh $ROM_SYS_PATH $BOOT_ROM_DATA_PATH 
	ROM_VENDOR=aosp
fi
echo ROM_VENDOR=$ROM_VENDOR >> $MBS_LOG
/sbin/busybox cp /mbs/init.rc.temp /xdata/init.rc.temp

/sbin/busybox umount $mnt_dir
/sbin/busybox umount $mnt_data
#=========================================================================

#============================================================
#make init.rc 
#============================================================
if [ "$BUILD_TARGET" = '2' ]; then
	/sbin/busybox sh /mbs/init.multi.sh $ROM_ID $LOOP_CNT
	
	#/sbin/busybox sh /mbs/init.share.sh
else
	/sbin/busybox sh /mbs/init.single.sh 0
fi
# Set TweakGS2 properties
/sbin/busybox sh /mbs/init.tgs2.sh

/sbin/busybox cp /init.rc /xdata/init.rc

echo end of init >> $MBS_LOG
/sbin/busybox umount /xdata


#mbs dir remove,if single boot 
if [ "$BUILD_TARGET" != '2' ]; then
	rm -r /mbs
	rmdir /xdata
fi
##
