#!/bin/bash
cp -R upload/* ../upload_backup/
cp -R ../upload_backup/* upload
git pull
bundle exec rake db:migrate
killall ruby
bundle exec rails s -e production -d
tail -f log/production.log
