#!/sbin/busybox sh

#this file reserved future
# parameters
#  
if [ ! -d /xdata/share ]; then
	mkdir /xdata/share
fi

MBS_LOG=/xdata/mbs4.log

if [ -f /share/share/share_init.sh ]; then
	echo "detect share init script" >> $MBS_LOG
	rom_id=`cat /mbs/stat/bootrom`
	sh /share/share/share_init.sh > /share/share/share_init$rom_id.log
	echo "share init is done" >> $MBS_LOG
fi

