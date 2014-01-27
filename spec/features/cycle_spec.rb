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
                             :shut_off_submission => false,
                             :anonymise => false)
      @time = Time.now.to_s
    end

    it "lets you see it" do
      sign_in "u2222222"
      visit "/assignments/wireworld"
      click_on "Peer review cycles"

      expect(page).to have_content("Peer review cycles for Wireworld")
      expect(page).to have_css('div.cycle')
    end

    it "lets you activate it" do
      sign_in "u2222222"
      visit "/assignments/wireworld"
      click_on "Peer review cycles"
      click_on "Activate"
      expect(page).to have_content("Activated")
    end

    feature "activating peer review cycles" do
      before(:each) do
        PeerReviewCycle.first.activate!
      end

      it "shows peer review" do
        sign_in "u2222222"
        visit "/assignments/wireworld"
        expect(page).to have_content("Dolly O'Keefe (u5555551) (visible to Brooks Kris)")
        expect(page).to have_content("Brooks Kris (u5555552) (visible to Dolly O'Keefe)")
      end

      feature "viewing each other's stuff"
    end
  end
end
