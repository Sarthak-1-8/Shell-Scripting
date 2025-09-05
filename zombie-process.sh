#!/bin/bash

# Basic command to find zombie process. At 8th column i.e. STAT Z means zombie process
# ps axu | awk '$8 == "Z" || $8 == "Z+"'

DnT=$(date +%F_%H-%M-%S)

REPORT_FILE="ZOMBIE_PROCESS_${DnT}.txt"

echo "Scan conducted on $DnT" > $REPORT_FILE

# we can use ps to get only the column we need

# -e : select every process
# -o : allow to specift a user-defined format. 
# pid : process id
# ppid : parent process id (which we want to kill)
# stat : the process stat
# cmd : command name

ps -eo pid,ppid,stat | awk ' \
	$3 == "Z" {
		print "Zombie Found -> PID:", $1, " | \
	Parent PID:", $2
	}' >> $REPORT_FILE

# ---------------KILLING ZOMBIE PROCESSES-------------------

ps -eo ppid,stat | awk '$2 == "Z" {print $1}' | \
       	sort -u | \
       while read ppid; do
		echo "Zombie child found. Asking Parent process $ppid to clean up."
		kill -s SIGCHILD "$ppid"
	done

# -------LAST RESORT TO KILL PARENT PROCESS ITSELF----------



