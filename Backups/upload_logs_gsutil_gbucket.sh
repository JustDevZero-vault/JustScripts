#!/bin/bash

# This script is intended to be used in servers who have configured gcsfuse, for gsutil there will be another script.

# crontab -e information
# upload_logs_gsutil_gbucket
#30 10 * * * /root/scripts/upload_logs_gsutil_gbucket.sh /root/scripts/services.list >> /var/log/upload_logs_gbucket.log

# Initial variables

days_older="7"
gbucket="google-bucket"
fformat="gz"
filename=$1
folder="server1"
total_files="0"
upload_correct="0"
upload_error="0"

echo `date +%Y-%m-%d` "Starting backup and delete process ..."

# Reads the file passed to the script to locate the service and the folder to search the logs to be uploaded

while read line
do
    # Each service/log is established in each line separating both service and his log by a space, so with this we save the value of each into a variable

    service=$(echo $line | awk '{print $1}')
    log=$(echo $line | awk '{print $2}')

    echo `date +%Y-%m-%d` "Uploading $service logs ..."

    for upload in $(find $log/*.$fformat -mtime +$days_older)
    do
        file=$(echo $upload | awk -F/ '{print $NF}')
        gsutil cp $upload gs://$gbucket/$folder/$service/
        hash_local=$(gsutil hash $upload | grep crc32c | awk '{print $3}')
        hash_bucket=$(gsutil ls -L gs://$gbucket/$folder/$service/$file | grep crc32c | awk '{print $3}')
        total_files=$(($total_files + 1))
        if [ $hash_local == $hash_bucket ];
        then
            echo `date +%Y-%m-%d` "File $upload uploaded"
            rm $upload
            upload_correct=$(($upload_correct + 1))
        else
            gsutil rm gs://$gbucket/$folder/$service/$file
            echo `date +%Y-%m-%d` "ERROR - $upload CRC32C MISMATCH"
            upload_error=$(($upload_error + 1))
        fi
    done

    echo `date +%Y-%m-%d` "$service logs uploaded"
done <<< "$(cat $filename)"

echo `date +%Y-%m-%d` "Upload proccess finished : $upload_correct files uploaded and $upload_error failed of $total_files files"
