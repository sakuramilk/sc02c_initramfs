#!/sbin/busybox sh

# parameters
#  $1 = LOOP_CNT

#set config
INIT_RC_DST=/init.rc
INIT_RC_SRC=/mbs/init.rc.temp
#--------------
n=`grep -n @ROM_SYS_PART_STA $INIT_RC_SRC | cut -d':' -f1`
head -n $n $INIT_RC_SRC > $INIT_RC_DST
#--------------
#==========================================================================
# System
#==========================================================================
echo  " 
#------------------------------
    mkdir /system
    chown root root /system
    chmod 0775 /system
    mount ext4 /dev/block/mmcblk0p9 /system wait ro
#------------------------------
 " >> $INIT_RC_DST

#==========================================================================
# /data
#==========================================================================
n=`grep -n @ROM_SYS_PART_END $INIT_RC_SRC | cut -d':' -f1`
m=`grep -n @ROM_DATA_PART_STA $INIT_RC_SRC | cut -d':' -f1`
sed -n "$n,${m}p" $INIT_RC_SRC >> $INIT_RC_DST 


echo  " 
#------------------------------
    # use movinand second partition as /data.
    mkdir /data

    exec check_filesystem /dev/block/mmcblk0p10 ext4
    mount ext4 /dev/block/mmcblk0p10 /data nosuid nodev noatime wait crypt discard,noauto_da_alloc

    chown system system /data
    chmod 0771 /data
#------------------------------
 " >> $INIT_RC_DST


#--------------
n=`grep -n @ROM_DATA_PART_END $INIT_RC_SRC | cut -d':' -f1`
m=`wc -l $INIT_RC_SRC| cut -d' ' -f1`
sed -n "$n,${m}p" $INIT_RC_SRC >> $INIT_RC_DST 
#/sbin/busybox cp $INIT_RC_DST /xdata/mbs_init.rc.out2
#---------------------------

