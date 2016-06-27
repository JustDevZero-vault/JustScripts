# Backups

Here you will find all the scripts I used as a SysAdmin Junior. This means that lots of them will have unoptimized / bad ways to do things.

## Rackspace

To use this script you will need to have installed at your server **swift**.

* [swiftBackup.sh](https://github.com/JustDevNull/JustScripts/blob/master/Backups/swiftBackup.sh)

## Google Cloud

This scripts were made to upload compressed logs that were X days old. Both of them reads a file (in this case is called services.list) that it's passed to the script at the time this is executed and reads each line, in which the information of the origin and destinations is stablished in each line separated by a space. The first column is considered the destination at the bucket and the second the origin of the logs to upload.

**IMPORTANT** : the first part **doesn't** have to start with a slash, and both columns **never** have to finish with a slash either.

Logically the servers need the Google Cloud SDK installed with a service account configured who has permissions to write.

* [upload_logs_gcsfuse_gbucket.sh](https://github.com/JustDevNull/JustScripts/blob/master/Backups/upload_logs_gcsfuse_gbucket.sh)
* [upload_logs_gsutil_gbucket.sh](https://github.com/JustDevNull/JustScripts/blob/master/Backups/upload_logs_gsutil_gbucket.sh)

Remember to look at the [GSUTIL](https://cloud.google.com/storage/docs/gsutil) and [GCSFUSE](https://cloud.google.com/storage/docs/gcs-fuse) documentation if needed.
