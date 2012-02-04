#!/sbin/busybox sh

# parameters
#  $1 = ROM_ID
#  $2 = LOOP_CNT

#set config
INIT_RC_DST=/init.rc
INIT_RC_SRC=/mbs/init.rc.temp

#LOOP_CNT="$2"
LOOP_CNT="0 1 2 3 4 5 6 7"
MBS_LOG=/xdata/mbs4.log
#----------------------------
# /system
#----------------------------
mnt_base=/mbs/mnt/rom$1
mnt_dir=$mnt_base/sys_dev

n=`grep -n @ROM_SYS_PART_STA $INIT_RC_SRC | cut -d':' -f1`
head -n $n $INIT_RC_SRC > $INIT_RC_DST

echo  "  #-- /system
    mkdir $mnt_dir
    chown root root $mnt_dir
    chmod 0775 $mnt_dir
    mount ext4 $ROM_SYS_PART $mnt_dir wait ro
    symlink $ROM_SYS_PATH /system
 " >> $INIT_RC_DST
#------------------------------

#----------------------------
# /data
#----------------------------
n=`grep -n @ROM_SYS_PART_END $INIT_RC_SRC | cut -d':' -f1`
m=`grep -n @ROM_DATA_PART_STA $INIT_RC_SRC | cut -d':' -f1`
sed -n "$n,${m}p" $INIT_RC_SRC >> $INIT_RC_DST 

echo  "  
#------------------------------
    mkdir /xdata
    exec check_filesystem /dev/block/mmcblk0p10 ext4
    mount ext4 /dev/block/mmcblk0p10 /xdata nosuid nodev noatime wait crypt discard,noauto_da_alloc
    chown system system /xdata
    chmod 0775 /xdata

	mkdir /share
    chown system system /share
    chmod 0771 /share
 " >> $INIT_RC_DST

for i in $LOOP_CNT; do
	mnt_base=/mbs/mnt/rom${i}
	mnt_dir=$mnt_base/data_dev
	#echo "#-- rom$i data mount & link to /share/data$i"  >> $INIT_RC_DST 
	eval ROM_DATA_PART=$"ROM_DATA_PART_"$i
	eval ROM_DATA_PATH=$"ROM_DATA_PATH_"$i

	if [ ! -z "$ROM_DATA_PART" ]; then
#--------------------

echo " #---rom${i}.data
    mkdir $mnt_dir
    chown system system $mnt_dir
    chmod 0775 $mnt_dir
    mount ext4  $ROM_DATA_PART $mnt_dir nosuid nodev noatime wait crypt discard,noauto_da_alloc
    #link for share app
    symlink $ROM_DATA_PATH /share/data${i}
#------------------------------
 " >> $INIT_RC_DST
#--------------------
	fi
done

echo "#-- active rom data link to /data
    symlink $BOOT_ROM_DATA_PATH /data

#-- app share data link to /share share
    symlink /xdata/share /share/share  
 " >> $INIT_RC_DST  
#--------------

n=`grep -n @ROM_DATA_PART_END $INIT_RC_SRC | cut -d':' -f1`
m=`wc -l $INIT_RC_SRC| cut -d' ' -f1`
sed -n "$n,${m}p" $INIT_RC_SRC >> $INIT_RC_DST 

#---------------------------




