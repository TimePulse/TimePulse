#!/bin/bash

DEPLOY_DIR=/var/www/tracks.lrdesign.com
PROJECT_TLA=tracks
S3_DIR=s3://appserver-backups/$PROJECT_TLA/

export RAILS_ENV=production
cd $DEPLOY_DIR/current

bundle exec nice rake db:backups:cycle 2>&1 > tmp/backup.output
if [ ! $? ]; then
 cat tmp/backup.output
fi

s3cmd sync --skip-existing --delete-removed $DEPLOY_DIR/current/db_backups $S3_DIR 2>&1 >> tmp/backup.output
if [ ! $? ]; then
 cat tmp/backup.output
fi

s3cmd sync --skip-existing --delete-removed $DEPLOY_DIR/shared/system $S3_DIR 2>&1 >> tmp/backup.output
if [ ! $? ]; then
 cat tmp/backup.output
fi




