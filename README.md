# Submission App

## Usage

Like all Rails apps, running `rails s` will launch the app and respond to queries on port 3000. You change the port to 8080 by running `rails server -p 8080`.

If you want to detach the process so that you can log out of your shell with the server still running, run `rails s -d`.

If the server is running in a detached process and you want it to stop, run `killall ruby`.

If you want to run the server so that it doesn't check passwords, run `DONT_CHECK_PASSWORDS='true' rails s`, with the `-d` flag if necessary.

The server only responds to HTTPS requests.

Protip: if you want to watch the server log as the server writes to it, run `tail -f log/production.log`. This is better than restarting the rails server without detaching it, because if you get bored and wander away, the server doesn't stop because your SSH gets logged out. (This problem happens to me often.)

## Installation

This project uses Rails 3.2.15, as it says in the Gemfile.

Currently, it uses sqlite3 for a database. This will probably change before the project goes into production. It also stores data files in `/upload`.

On a Mac, get Rails set up, install necessary dependencies with `bundle install`. Then run `rake db:reset` to get the database set up. To seed it with demo data, run `rake db:seed`.

On Ubuntu, if you run the `ubuntu_setup.sh` script, it should install necessary dependencies and get the whole thing set up.

To run the tests, first run `rake db:test:prepare`, then run `rspec`. You should see lots of pretty green lines.

## Dependencies

This uses the `zip` shell command. It uses `ghc` to check if Haskell assignments compile, if that's enabled for the assignment. Various basic *nix shell commands are hard coded in submission related code.

## Miscellaneous

I've used American English throughout in spelling of variable names etc.

I log suspicious activity with "Security warning" in the server log. At some point in the future, I'll give the admin notifications whenever that occurs.