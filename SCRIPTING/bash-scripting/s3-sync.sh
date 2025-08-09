#!/bin/bash

SOURCE="/var/www/html"
DESTINATION="s3://my-tf-state6464/ec2-backup/"

aws s3 sync "$SOURCE" "$DESTINATION" --delete >> /var/log/s3_sync.log 2>&1
if [ $? -ne 0 ]; then
    echo "$(date): S3 sync failed" >> /var/log/s3_sync.log
else
    echo "$(date): S3 sync completed successfully" >> /var/log/s3_sync.log
fi