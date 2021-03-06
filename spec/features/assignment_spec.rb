require 'spec_helper'

feature "creating assignments" do
  before(:each) do
    dolly = User.create!(:name => "Dolly O'Keefe", :uni_id => 5555551)
    uwe = User.create!(:name => "Uwe Zimmer", :uni_id => 2222222)
    comp1100 = Course.create!(:name => "Comp1100", :convener_id => uwe.id)
    dolly.enroll_in_course!(comp1100)
    tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1100])
    thursday_tute = Group.create!(:name => "Thursday A", :group_type_id => tute.id)
  end

  it "has a create page" do
    sign_in("u2222222")
    visit "/group_types/1/assignments/new"
    expect(page).to have_content("New assignment")
  end

  feature "lets you create assignments" do
    before(:each) do
      sign_in("u2222222")
      visit "/group_types/1/assignments/new"
      fill_in 'assignment_name', :with => "Wireworld "
      fill_in "Assignment description", :with => "Cellular automata!!!"
      click_button "Create assignment"
    end

    it "has a show page" do
      expect(page).to have_content "Wireworld"
      expect(page).to have_content "Cellular automata!!!"
    end

    it "is visible to others" do
      sign_out
      sign_in("u5555551")

      visit "/assignments/1"
      expect(page).to have_content "Wireworld"
      expect(page).to have_content "Cellular automata!!!"
    end
  end
end

feature "making assignments with helper method" do
  it "seems to let you submit things correctly" do
    set_up_example_course
    submit_wireworld_as_user("u5555551")
    submit_wireworld_as_user("u5555552")
    sign_in "u2222222"
    visit "/assignments/wireworld"
    expect(page).to have_content("Download all submissions as zip")
    expect(page).to have_content("Dolly O'Keefe (u5555551)")
    expect(page).to have_content("Brooks Kris (u5555552)")
  end
end