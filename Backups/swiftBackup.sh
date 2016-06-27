#!/bin/bash

# This is a script to upload logs to Rackspace container

# Authentication data
user="rackspace-user"
apikey="rackspace-api-key"
authversion="1.0"
authurl="https://identity.api.rackspacecloud.com/v1.0/"

# Host and container data
hostname=`hostname`
containerroot="container-root-folder"
container=$containerroot/$hostname

# Directory of the logs
folder="/var/log/"

# Makes md5 file of the files begin to upload to late comparisson, this files have to be 1 week older minimum

echo "Finding the files to upload..."
find $folder -mtime +7 -name "*.gz" -exec md5sum > /tmp/md5_raw.txt {} \;
echo "Files found"

# Make the list of the unique MD5 of each and the files begin uploaded for late comparisson

cut -d " " -f 1 /tmp/md5_raw.txt > /tmp/md5.txt

cut -d " " -f 2- /tmp/md5_raw.txt > /tmp/md5_files.txt

# Upload the files to the Rackspace container

echo "Uploading..."

for line in $(cat /tmp/md5_files.txt)
do
        swift -A $authurl -U $user -K $apikey upload $container $line -S 4073741824
done

echo "Upload complete"

# Obtain the raw data of the uploaded files to the container

echo "Checking the MD5 in both origin/destination---"

for line in $(cat /tmp/md5_files.txt)
do
       swift -v -V $authversion -A $authurl -U $user -K $apikey stat $containerroot $hostname$line >> /tmp/md5_container_raw.txt
done

# Cleans the raw information to only obtain the MD5 data of the files in the container

grep -R "ETag" /tmp/md5_container_raw.txt >> /tmp/md5_container_raw_2.txt

cut -d " " -f 12- /tmp/md5_container_raw_2.txt >> /tmp/md5_container.txt

# Remove the files once uploaded if the MD5 is the same

if diff /tmp/md5.txt /tmp/md5_container.txt > /dev/null ;
then
    echo "The MD5 check was Ok"
    echo "Deleting local files..."
	find $folder -mtime +7 -name "*.gz" -exec rm -r {} \;
	echo "Local files deleted"
else
	echo "ERROR!! The MD5 from local and container files doesn't match!!"
fi

# Remove the temporal files

rm /tmp/md5_raw.txt /tmp/md5.txt /tmp/md5_files.txt /tmp/md5_container_raw.txt /tmp/md5_container_raw_2.txt /tmp/md5_container.txt

echo "Temp files removed"
echo "Done"
