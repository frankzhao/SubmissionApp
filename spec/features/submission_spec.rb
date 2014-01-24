require 'spec_helper'

feature "submitting assignments" do
  before(:each) do
    set_up_example_course
  end

  it "lets you submit assignments" do
    sign_in "u5555551"
    visit "/assignments/wireworld/assignment_submissions/new"
    expect(page).to have_content("New assignment submission for Wireworld")
    fill_in "submission[body]", :with => "main = undefined"
    click_button "Submit!"
    expect(page).to have_content("Submission for Wireworld")
    expect(page).to have_content("main = undefined")
  end

  feature "access from other users" do
    before(:each) do
      submit_wireworld_as_user("u5555551")
    end

    it "is visible to the person who submitted it" do
      sign_in "u5555551"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("Submission for Wireworld")
      expect(page).to have_content("main = \"u5555551\"")
    end

    it "is visible to the tutor of the person who submitted it" do
      sign_in "u5192430"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("Submission for Wireworld")
      expect(page).to have_content("main = \"u5555551\"")
    end

    it "is not visible to other tutors" do
      sign_in "u5423452"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("You don't have permission to access that page")
      expect(page).to_not have_content("Submission for Wireworld")
      expect(page).to_not have_content("main = \"u5555551\"")
    end

    it "is not visible to other people" do
      sign_in "u5555552"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("You don't have permission to access that page")
      expect(page).to_not have_content("Submission for Wireworld")
      expect(page).to_not have_content("main = \"u5555551\"")
    end

    feature "comments" do
      ["u5555551", "u2222222", "u5192430"].each do |uni_id|
        feature "letting the submitter comment as #{uni_id}" do
          before(:each) do
            sign_in uni_id
            visit "/assignments/wireworld/assignment_submissions/1"
            within(:css, "div#comment-") do
              fill_in "comment[body]", :with => "look at #{uni_id} commenting"
              click_on "Post comment"
            end
            sign_out
          end

          ["u5555551", "u2222222", "u5192430"].each do |viewer_id|
            it "lets #{viewer_id} see it" do
              sign_in viewer_id
              visit "/assignments/wireworld/assignment_submissions/1"
              expect(page).to have_content("look at #{uni_id} commenting")
            end
          end
        end
      end
    end
  end
end