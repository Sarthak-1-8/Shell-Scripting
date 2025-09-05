#!/bin/bash


# if there is no argument then take default TARGET DIR as .(current dir)
TARGET_DIR=${1:-.}

# if there is no argument then take default value of N as 10
N=${2:-10}

REPORT_FILE="report_file_$(date +%F_%H-%M-%S).txt"

if [ ! -d "$TARGET_DIR" ]; then
	echo "Directory not does not exit"
	exit 1
fi

# echo "$#"

if [ "$#" -gt 2 ]; then
	echo "More arguments then needed"
	echo "first argument for Target dir....default Target is current dir"
	echo "second argument for top N....default N is 10"
	exit 1
fi


echo " Searching for the top $N largest files in $TARGET_DIR..."

echo "............................................................"

find "$TARGET_DIR" -type f -printf "%s %p\n" | sort -rn | head -n "$N" | tee $REPORT_FILE 




