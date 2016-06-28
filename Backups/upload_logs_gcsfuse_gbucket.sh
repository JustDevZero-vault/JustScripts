#!/bin/bash

# crontab -e information
# upload_logs_gcsfuse_gbucket
#30 10 * * * /root/scripts/upload_logs_gcsfuse_gbucket.sh >> /var/log/upload_logs_gcsfuse_gbucket.log

# Initial variables

days_older="7"
gbucket="google-bucket"
fformat="gz"
filename=$1
folder="server1"
hostname=`hostname`
mount_error="0"
mount_point="/mnt/backup"
today=`date +%Y-%m-%d`
total_files="0"
upload_correct="0"
upload_error="0"

echo `date +%Y-%m-%d` "Starting backup and delete process ..."

# First we check if the mount point exists, and if not create it

if [[ ! -d $mount_point ]];
then
    mkdir -p $mount_point
fi

# Mount the bucket

mount -t gcsfuse -o rw,user $gbucket $mount_point

# Checks if the folder is mounted correctly, and if it fails then finish the script

mount_check=`ls $mount_point | wc -l`

if [ $mount_check == $mount_error ];
then
    umount $mount_point
    echo `date +%Y-%m-%d` "Mount process failed"
    echo `date +%Y-%m-%d` "Backup and delete process stoped"
    mnt_error=$(echo `date +%Y-%m-%d` "The server $hostname encountered an error trying to mount the mount point $mount_point")
    /root/scripts/zbxtg.sh "username" "$hostname upload script at $today" "$mnt_error"
    exit 1
fi

# Reads the file passed to the script to locate the service and the folder to search the logs to be uploaded

while read line
do
    # Each service/log is established in each line separating both service and his log by a space, so with this we save the value of each into a variable

    service=$(echo $line | awk '{print $1}')
    log=$(echo $line | awk '{print $2}')

    # Checks if the folder exists in the bucket, and if not create it before the upload.

    if [[ ! -d $mount_point/$folder/$service ]];
    then
        mkdir -p $mount_point/$folder/$service
    fi

    echo `date +%Y-%m-%d` "Uploading $service logs ..."

    for upload in $(find $log/*.$fformat -mtime +$days_older)
    do
        file=$(echo $upload | awk -F/ '{print $NF}')
        cp $upload $mount_point/$folder/$service/
        hash_local=$(md5sum $upload | awk '{print $1}')
        hash_bucket=$(md5sum $mount_point/$folder/$service/$file | awk '{print $1}')
        total_files=$(($total_files + 1))
        if [ $hash_local == $hash_bucket ]
        then
            echo `date +%Y-%m-%d` "File $upload uploaded"
            #rm $upload
            upload_correct=$(($upload_correct + 1))
        else
            rm $mount_point/$folder/$service/$file
            echo `date +%Y-%m-%d` "ERROR - $upload MD5SUM MISMATCH"
            upload_error=$(($upload_error + 1))
        fi
    done

    echo `date +%Y-%m-%d` "$service logs uploaded"
done <<< "$(cat $filename)"

# Dismounts the folder and checks if was successfully dismounted

umount $mount_point

mount_check_final=`ls $mount_point | wc -l`

if [ $mount_check_final == $mount_error ];
then
    echo `date +%Y-%m-%d` "Umount process finished"
else
    echo `date +%Y-%m-%d` "Umount process failed!!"
fi

message=$(echo `date +%Y-%m-%d` "Upload proccess finished : $upload_correct files uploaded and $upload_error failed of $total_files files")

echo $message

/root/scripts/zbxtg.sh "username" "$hostname upload script at $today" "$message"
