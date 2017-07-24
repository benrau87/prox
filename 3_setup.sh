
mdadm --manage --examine /dev/sdb
echo "If there was a superblock, please delete then off all disks that are going to be used."
echo "Run  mdadm --misc --zero-superblock /dev/sdb /dev/sdc.. for all disks."
echo "Then de
echo
echo "How many drives are you using?"
read count
echo "What are their paths? eg.. /dev/sda /dev/sdb..."
read disks
echo "Creating array"
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=$count "$disks"
tail -f /proc/mdstat
