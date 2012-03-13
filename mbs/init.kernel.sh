#!/sbin/busybox sh

export RET=""

#note)script process is "main process" is 1st
#------------------------------------------------------
#foce ROM0 boot setting
#	$1: error msg
#------------------------------------------------------
func_error()
{
	sh err_reboot.sh $1
}

#------------------------------------------------------
# write Kernel MD5
#   $1 kernel path
#    no check mbs.conf exist
#
#	@todo
#------------------------------------------------------
func_compare_current_md5()
{
	echo "select hernel=$1" >> $MBS_LOG

	# current kernel md5 checksum
	size=`stat -t $1 | cut -d ' ' -f2`
	echo size=$size >> $MBS_LOG
	dd if=$DEV_BLOCK_ZIMAGE of=/tmp/zImage ibs=1 count=$size
	curr_md5=`md5sum /tmp/zImage | cut -d ' ' -f1`
	# select kernel md5 checksum
	sel_md5=`md5sum $1 | cut -d ' ' -f1`

	# check md5
	echo curr_md5=$curr_md5 >> $MBS_LOG
	echo sel_md5=$sel_md5 >> $MBS_LOG
	if [ ! "$curr_md5" = "$sel_md5" ]; then
		cat $1 > $DEV_BLOCK_ZIMAGE
		sync
		sync
		sync
		reboot
	fi
}

#==============================================================================
# main process
# $1 : KERNEL_PART
# $2 : KERNEL_IMG
#==============================================================================
KERNEL_PART=$1
KERNEL_IMG=$2
#for Debug
echo KERNEL_PART=$KERNEL_PART >> $MBS_LOG
echo KERNEL_IMG=$KERNEL_IMG >> $MBS_LOG

mnt_base=/mbs/mnt/kernel

if [ -n "$KERNEL_PART" ] && [ "$KERNEL_PART" != "$DEV_BLOCK_ZIMAGE" ]; then
	if [ -n "$KERNEL_IMG" ]; then
		mount -t ext4 $KERNEL_PART $mnt_base || func_error "$KERNEL_PART is invalid part"
	
		if [ -f "$mnt_base$KERNEL_IMG" ]; then
			func_compare_current_md5 "$mnt_base$KERNEL_IMG"
		else
			func_error "$mnt_base$KERNEL_IMG is not exist"
		fi

		umount $mnt_base
	fi
fi


exit 0
##
