#!/bin/bash

####################################################################################################################

#incorporate brad's signatures in to signatures/cross, remove andromedia/dridex_apis/chimera_api/deletes_self/cryptowall_apis


if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
gitdir=$PWD

##Logging setup
logfile=/var/log/proxupdate.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

##Functions
function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

function error_check
{

if [ $? -eq 0 ]; then
	print_good "$1 successfully."
else
	print_error "$1 failed. Please check $logfile for more details."
exit 1
fi

}

function install_packages()
{

apt-get update &>> $logfile && apt-get install -y --allow-unauthenticated ${@} &>> $logfile
error_check 'Package installation completed'

}

function dir_check()
{

if [ ! -d $1 ]; then
	print_notification "$1 does not exist. Creating.."
	mkdir -p $1
else
	print_notification "$1 already exists. (No problem, We'll use it anyhow)"
fi

}
########################################
##BEGIN MAIN SCRIPT##
#Pre checks: These are a couple of basic sanity checks the script does before proceeding.
mdadm --manage --examine /dev/sdb
echo "If there was a superblock, please delete then off all disks that are going to be used."
echo "Run  mdadm --misc --zero-superblock /dev/sdb /dev/sdc.. for all disks."
echo "Then delete metadata off each disk with dd if=/dev/zero of=/dev/sdN bs=1M count=100, run for 5 secs and CTRL-C"
echo "Use fdisk to partition and set raid flag, fdisk /dev/sdN -> o, p, n, p, 1, t, fd, w"
echo
echo "How many drives are you using?"
read count
echo "What are their paths? eg.. /dev/sda /dev/sdb..."
read disks
echo "Creating array"
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=$count "$disks"
echo "Use cat /proc/mdadm to check process, once completed move to 3_setup.sh"
