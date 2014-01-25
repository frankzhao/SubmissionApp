require "spec_helper"

feature "peer review cycles" do
  before(:each) do
    set_up_example_course
    submit_wireworld_as_user("u5555551")
    submit_wireworld_as_user("u5555552")
  end

  feature "making peer review cycles" do
    it "lets you see the cycle creation page" do
      sign_in "u2222222"
      visit "/assignments/wireworld"
      click_on "Peer review cycles"

      expect(page).to have_content("Peer review cycles for Wireworld")
    end
  end

  feature "using peer review cycles" do
    before(:each) do
      PeerReviewCycle.create(:assignment_id => 1,
                             :distribution_scheme => "swap_simultaneously",
                             :shut_off_submission => false)
    end

    it "lets you see it" do
      sign_in "u2222222"
      visit "/assignments/wireworld"
      click_on "Peer review cycles"

      save_and_open_page

      expect(page).to have_content("Peer review cycles for Wireworld")
    end
  end
end
