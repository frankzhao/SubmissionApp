# These are instructions for getting the submission app working on a clean
# Ubuntu install.

# It expects to be run from within the project directory. So start out by cloning
# my Git repo at https://github.com/BuckShlegeris/SubmissionApp.git

# I've tested this on clean Vagrant installs, and it works there.

# Please feel free to email or Skype me at buckmbs@hotmail.com

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

# This installs a JS runtime, which Rails needs
sudo apt-get install nodejs -y

# This installs the Rails dependencies
bundle install
sh setup.sh

echo "Run `rails server` to see it running on port 3000"