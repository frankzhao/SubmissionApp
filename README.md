# Submission App


## Installation

This project uses Rails 3.2.15, as it says in the Gemfile.

Currently, it uses sqlite3 for a database. This will change before the project goes into production. It also stores data files in `/upload`.

Once you download it, install necessary dependencies with `bundle install`. Then run `rake db:reset` to get the database set up. To seed it with demo data, run `rake db:seed`.

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
	- Katelyn Collier (u5817236)
	- Brooks Kris (u4911177)
- A user who is in 1100 and hasn't is Demarcus Johns, u4500384.
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
- As Uwe, click the "Start Peer Review" button on an assignment webpage. This means that each student who has submitted something gets access to a random other student's most recent submission. They can comment on it. Neither the reviewer nor the reviewee see each other's names.

## Miscellaneous

I've used American English throughout.