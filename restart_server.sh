#!/bin/bash
cp -R upload/* ../upload_backup/
git pull
cp -R ../upload_backup/* upload
bundle exec rake db:migrate
killall ruby
bundle exec rails s -e production -d
tail -f log/production.log
