#!/bin/bash

# NOTE: this file should be run hourly to execute the backups
cd /home/devel/app

nice rake db:backups:cycle RAILS_ENV=production 2>&1 > /home/devel/backup.output
if [ ! $? ]; then
    cat /home/devel/backup.output
fi