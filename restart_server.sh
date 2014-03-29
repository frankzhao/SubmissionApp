#!/bin/bash

git pull
bundle exec rake db:migrate
killall ruby
bundle exec rails s -e production -d
tail -f log/production.log
