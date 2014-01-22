
# Instructions slightly altered from https://www.digitalocean.com/community/articles/how-to-install-ruby-on-rails-on-ubuntu-12-04-lts-precise-pangolin-with-rvm
# See there for more details.
sudo apt-get update
sudo apt-get install curl -y
\curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
rvm install ruby
rvm use ruby --default
rvm rubygems current
gem install rails --no-ri --no-rdoc
sudo apt-get install git -y

# This installs a JS runtime, which Rails needs
sudo apt-get install nodejs -y

# This downloads my code
git clone https://github.com/BuckShlegeris/SubmissionApp.git

# This sets it up
cd SubmissionApp

bundle install
sh setup.sh

# This runs it
rails server