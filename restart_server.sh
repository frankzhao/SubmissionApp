#!/bin/bash
cp -R upload/* ../upload_backup/
git pull
bundle exec rake db:migrate
killall ruby
bundle exec rails s -e production -d
cp -R ../upload_backup/* upload
tail -f log/production.log
