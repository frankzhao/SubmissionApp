require "spec_helper"

feature "peer review cycles" do
  before(:each) do
    set_up_example_course
  end

  ["swap_simultaneously", "send_to_previous", "send_to_next"].each do |scheme|
    feature "making peer review cycles" do
      it "lets you see the #{scheme} cycle creation page" do
        sign_in "u2222222"
        visit "/assignments/wireworld"
        click_on "Peer review cycles"

        expect(page).to have_content("Peer review cycles for Wireworld")
      end

    feature "using swap_simultaneously" do
      before(:each) do
        PeerReviewCycle.destroy_all
        PeerReviewCycle.create(:assignment_id => 1,
                               :distribution_scheme => scheme,
                               :shut_off_submission => false,
                               :anonymise => false)
        submit_wireworld_as_user("u5555551")
        submit_wireworld_as_user("u5555552")


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
    end
  end

  feature "using swap_simultaneously"
    before(:each) do
      PeerReviewCycle.create(:assignment_id => 1,
                               :distribution_scheme => scheme,
                               :shut_off_submission => false,
                               :anonymise => false)
      submit_wireworld_as_user("u5555551")
      submit_wireworld_as_user("u5555552")
    end

    feature "viewing peer assignments" do
      before(:each) do
        PeerReviewCycle.first.activate!
      end

      it "shows peer review" do
        sign_in "u2222222"
        visit "/assignments/wireworld"
        expect(page).to have_content("Dolly O'Keefe (u5555551) (visible to Brooks Kris)")
        expect(page).to have_content("Brooks Kris (u5555552) (visible to Dolly O'Keefe)")
      end

      it "lets peers see their assignments" do
        pending "me doing stuff" do
          sign_in "u5555551"
          visit "/assignments/wireworld/assignment_submissions/2"
          fail
          # todo
        end
      end
    end
  end

  feature "using send_to_previous" do
    before(:each) do
      PeerReviewCycle.create(:assignment_id => 1,
                       :distribution_scheme => "send_to_previous",
                       :shut_off_submission => false,
                       :anonymise => false)
    end

  end
end
