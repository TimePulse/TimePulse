#!/bin/bash
cd /home/lrd/tracks.lrdesign.com.com/current

nice rake db:backups:cycle RAILS_ENV=production 2>&1 > /home/lrd/tmp/backup.output
if [ ! $? ]; then
    cat /home/lrd/tmp/backup.output
fi
