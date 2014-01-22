# Submission App


## Installation

This project uses Rails 3.2.15, as it says in the Gemfile.

Currently, it uses sqlite3 for a database. This will probably change before the project goes into production. It also stores data files in `/upload`.

On a Mac, get Rails set up, install necessary dependencies with `bundle install`. Then run `rake db:reset` to get the database set up. To seed it with demo data, run `rake db:seed`.

On Ubuntu, if you run the `ubuntu_setup.sh` script, it should install necessary dependencies and get the whole thing set up. 

To run the tests, first run `rake db:test:prepare`, then run `rspec`. You should see lots of pretty green lines.

I've tested this on the following machines:
- Mac OS 10.9 basically before every commit
- Mac OS 10.8: 10 Jan 2014
- Ubuntu 13.04: 10 Jan 2014

## Usage

Like all Rails apps, running `rails s` will launch the app and respond to queries on port 3000. You change the port to 8080 by running `rails server -p 8080`.

## Dependencies

This uses the `zip` shell command. It uses `ghc` to check if Haskell assignments compile, if that's enabled for the assignment. Various *nix shell commands are hard coded in submission related code.

## Using the demo

Currently, no passwords are required. This is because the authentication is running through the ANU LDAP server, and I don't have a bunch of ANU LDAP passwords and usernames which I can use for testing.

The seed database includes, among other items:

- Uwe, who convenes 1100 and 1130. Uwe's username is u2222222.
- Buck, who has an 1100/1130 lab. Buck's username is u5192430.
- The two users who have submitted Wireworld are:
	- Katelyn Collier (u5555551)
	- Brooks Kris (u5555552)
- A user who is in 1100 and hasn't is Demarcus Johns, u5555553.
- James Fellows, who is an admin. His username is u1234567.

Things you can do:

- As anyone, click around and look at things.
- As a student of 1100/1130, submit text to Wireword or a zip to Kalaha.
- As Buck, view submissions from students in your tute.
- As Uwe, view submissions from everyone.
- As anyone, who has access to a submission, comment on it.
- Currently, Wireworld is set up to put an automatic comment on submissions as to whether they compile.
- As Uwe, download a zip of all submissions or a csv of all marks.
- As Uwe or James, create a course and upload students by CSV.
- As Uwe, access the peer review cycles for an assignment under the Edit pane. This lets you create peer review cycles and activate them.

## Miscellaneous

I've used American English throughout in spelling of variable names etc.