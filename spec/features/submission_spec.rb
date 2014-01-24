require 'spec_helper'

feature "submitting assignments" do
  before(:each) do
    dolly = User.create!(:name => "Dolly O'Keefe", :uni_id => 5555551)
    uwe = User.create!(:name => "Uwe Zimmer", :uni_id => 2222222)
    comp1100 = Course.create!(:name => "Comp1100", :convener_id => uwe.id)
    dolly.enroll_in_course!(comp1100)
    tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1100])
    thursday_tute = Group.create!(:name => "Thursday A", :group_type_id => tute.id)

    sign_in "u2222222"
    visit "/group_types/1/assignments/new"
    fill_in 'assignment_name', :with => "Wireworld"
    fill_in "Assignment description", :with => "Cellular automata!!!"
    fill_in "assignment_behavior_on_submission", :with => "check_compiling_haskell"
    click_button "Create assignment"
    sign_out "Uwe Zimmer"
  end

  it "lets you submit assignments" do
    sign_in "u5555551"
    visit "/assignments/wireworld/assignment_submissions/new"
    expect(page).to have_content("New assignment submission for Wireworld")
    fill_in "submission[body]", :with => "main = undefined"
    click_button "Submit!"
    expect(page).to have_content("Submission for Wireworld")
    expect(page).to have_content("main = undefined")
    expect(page).to have_content("This code compiles!")
  end

  it "complains about invalid Haskell" do
    sign_in "u5555551"
    visit "/assignments/wireworld/assignment_submissions/new"
    expect(page).to have_content("New assignment submission for Wireworld")
    fill_in "submission[body]", :with => "main = 2 wre23undefined"
    click_button "Submit!"
    expect(page).to have_content("Submission for Wireworld")
    expect(page).to have_content("main = 2 wre23undefined")
    expect(page).to have_content("This code doesn't compile, with the following error:")
  end
end