# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

def sign_in(uni_id)
  visit "/"
  fill_in 'Uni ID', :with => uni_id
  click_button "Log in"
end

def sign_out
  click_on "Log Out"
end

def set_up_example_course
  dolly = User.create!(:name => "Dolly O'Keefe", :uni_id => 5555551)
  uwe = User.create!(:name => "Uwe Zimmer", :uni_id => 2222222)
  comp1100 = Course.create!(:name => "Comp1100", :convener_id => uwe.id)
  dolly.enroll_in_course!(comp1100)

  brooks = User.create!(:name => "Brooks Kris", :uni_id => 5555552)
  brooks.enroll_in_course!(comp1100)

  daniel = User.create!(:name => "Daniel Filan", :uni_id => 5555553)
  daniel.enroll_in_course!(comp1100)

  tute = GroupType.create!(:name => "Comp1100/1130 labs",
                       :courses => [comp1100])
  dolly.join_group!(tute)
  brooks.join_group!(tute)
  daniel.join_group!(tute)

  buck = User.create!(:name => "Buck Shlegeris", :uni_id => 5192430)
  buck.enroll_staff_in_course!(comp1100)
  buck_tute = tute.create_groups("Thursday A"=>[buck])

  tessa = User.create!(:name => "Tessa Bradbury", :uni_id => 5423452)

  wireworld = Assignment.create!(:name => "Wireworld",
                                 :info => "cellular automata!",
                                 :group_type_id => 1,
                                 :due_date => "2014-05-03 23:04:26")
  wireworld.add_marking_category!(:name => "Correctness",
                                  :description => "how wrong it is",
                                  :maximum_mark => 50)
end

def submit_wireworld_as_user(user)
  sign_in user
  visit "/assignments/wireworld/assignment_submissions/new"
  expect(page).to have_content("New assignment submission for Wireworld")
  fill_in "submission[body]", :with => "main = \"#{user}\""
  click_button "Submit!"
  sign_out
end

def mark_submission(uni_id, mark)
  sign_in uni_id
  visit "/assignments/wireworld/assignment_submissions/1"
  within(:css, "div#comment-") do
    fill_in "comment[body]", :with => "look at #{uni_id} commenting"
    fill_in "mark_Correctness", :with => "#{mark}"
    click_on "Post comment"
  end
  sign_out
end

def assignment_hash(name)
  {:name => name,
    :info => "this is very hard",
    :group_type_id => 1,
    :due_date => "2014-05-03 23:04:26"}
end