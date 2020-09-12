#!/bin/bash
# Daniel Schwartz
# 22.12.2016

# The script aims to check a HotSpot (mainly Tomcat) Thread Dump taken with a "kill -3"
# For the moment it's not working for WebSphere javacores

#Timestamp
time=$(date)

#Define LogFile
logfile="./threadstat_$1_$(date +"%Y%m%d%H%M").log"

echo "####### Started Script at $time #######" >> $logfile
echo '' >> $logfile
echo "Analysis of '$1' in progress ..." >> $logfile
echo '' >> $logfile

#Create Statistics of Threads
#java.lang.Thread.State: BLOCKED (on object monitor)

#Create Statistics of Stack Trace
stat1=$(egrep 'java.lang.Thread.State' $1 | awk '{print $2}' | sort | uniq -c | awk '{sum += $1; print} END {print sum, "TOTAL"}')
echo "#############################################################" >> $logfile
echo "In Summary we have following Thread Statistics:" >> $logfile
echo "$stat1" >> $logfile
echo '' >> $logfile
echo '' >> $logfile

#Automatic analysis

#Check thread id which cause the highest amount of thread to be blocked / locked
check1=$(egrep 'waiting to lock' $1 |  sed -n 's/.*[<@]\(.*\)[>[].*/\1/p' | sort | uniq -c)
echo "#############################################################" >> $logfile
echo "Checking all BLOCKED Threads for their 'LOCKS':" >> $logfile
echo "$check1" >> $logfile
echo '' >> $logfile
echo '' >> $logfile

#Check which tread is holding the lock
check2=$(egrep 'waiting to lock' $1 |  sed -n 's/.*[<@]\(.*\)[>[].*/\1/p' | sort | uniq)
for i in $check2
do
	echo "#############################################################" >> $logfile
	echo "The stack trace of the lock '$i' is:" >> $logfile
	printf "%b\n" $(more $1|sed -n '/locked\s<'"${i}"'>/,/^$/p') >> $logfile
	echo '' >> $logfile
	echo '' >> $logfile
done
