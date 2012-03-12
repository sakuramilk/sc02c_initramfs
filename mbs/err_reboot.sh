#!/sbin/busybox sh

echo $1 >> $MBS_LOG
echo $1 > $ERR_MSG
mv $MBS_CONF $MBS_CONF.keep
sync
sync
sync

umount /xdata
reboot recovery
