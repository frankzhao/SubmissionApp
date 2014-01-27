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

    it "is not visible to others even when there's a peer review cycle" do
      cycle = PeerReviewCycle.create(:assignment_id => 1,
                             :distribution_scheme => "swap_simultaneously",
                             :shut_off_submission => false,
                             :anonymise => false)
      cycle.activated = true
      cycle.save!

      sign_in "u5555552"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("You don't have permission to access that page")
      expect(page).to_not have_content("Submission for Wireworld")
      expect(page).to_not have_content("main = \"u5555551\"")
    end

    feature "peer review" do
      it "is invisible when cycles aren't activated" do
        cycle = PeerReviewCycle.create(:assignment_id => 1,
                               :distribution_scheme => "swap_simultaneously",
                               :shut_off_submission => false,
                               :anonymise => false)

        assignment_submission = AssignmentSubmission.find(1)
        assignment_submission.add_permission(User.find_by_uni_id(5555552), 1)

        p assignment_submission.permits? User.find_by_uni_id(5555552)

        sign_in "u5555552"
        visit "/assignments/wireworld/assignment_submissions/1"
        expect(page).to have_content("You don't have permission to access that page")
        expect(page).to_not have_content("Submission for Wireworld")
        expect(page).to_not have_content("main = \"u5555551\"")
      end

      it "is visible when cycles are activated" do
        cycle = PeerReviewCycle.create(:assignment_id => 1,
                               :distribution_scheme => "swap_simultaneously",
                               :shut_off_submission => false,
                               :anonymise => false)
        cycle.activated = true
        cycle.save!
        assignment_submission = AssignmentSubmission.find(1)
        assignment_submission.add_permission(User.find_by_uni_id(5555552), 1)

        sign_in "u5555552"
        visit "/assignments/wireworld/assignment_submissions/1"
        expect(page).to have_content("Submission for Wireworld")
        expect(page).to have_content("main = \"u5555551\"")
      end

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