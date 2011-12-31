


on multi-csc
	echo 
	echo "-- Appling Multi-CSC..."
	mount /system
	echo "Applied the CSC-code : <salse_code>"
	cp -y -f -r -v /system/csc/<salse_code> /
	cmp -r /system/csc/<salse_code> /
	echo "Successfully applied multi-CSC."

on preload
	echo
	echo "-- Updating application..."
	mount /preload
	echo "Successfully updated application."
