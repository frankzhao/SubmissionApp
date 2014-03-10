require 'spec_helper'

feature "viewing courses" do
  before(:each) do
    dolly = User.create!(:name => "Dolly O'Keefe", :uni_id => 4989649)
    uwe = User.create!(:name => "Uwe Zimmer", :uni_id => 2222222)
    comp1100 = Course.create!(:name => "Comp1100", :convener_id => uwe.id)
    dolly.enroll_in_course!(comp1100)
    wireworld = Assignment.create!(:name => "Wireworld",
                           :info => "cellular automata!",
                           :group_type_id => 1,
                           :due_date => "2014-05-03 23:04:26")
    tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1100])
    thursday_tute = Group.create!(:name => "Thursday A", :group_type_id => tute.id)
    visit new_sessions_url
    fill_in 'Uni ID', :with => "u4989649"
    click_button "Log in"
    visit "/courses/1"
  end

  it "has a show page" do
    expect(page).to have_content "Comp1100"
  end

  it "mentions assignments" do
    expect(page).to have_content "Wireworld"
  end

  it "mentions groups" do
    expect(page).to have_content "Thursday A"
  end

  it "lists students" do
    expect(page).to have_content "Dolly O'Keefe"
  end

  it "lets you click on assignments" do
    first(:link, "Wireworld").click
    expect(page).to have_content "cellular automata!"
  end
end

feature "viewing courses which you aren't in" do
  before(:each) do
    dolly = User.create(:name => "Dolly O'Keefe", :uni_id => 4989649)
    uwe = User.create(:name => "Uwe Zimmer", :uni_id => 2222222)
    course = Course.create(:name => "Comp1100", :convener_id => uwe.id)
    wireworld = Assignment.create!(:name => "Wireworld",
                           :info => "cellular automata!",
                           :group_type_id => 1,
                           :due_date => "2014-05-03 23:04:26")

    visit new_sessions_url
    fill_in 'Uni ID', :with => "u4989649"
    click_button "Log in"
    visit "/courses/1"


  end

  it "says you aren't enrolled" do
    expect(page).to have_content(
      "Note that you aren't enrolled in this course--you'd see more if you were.")
  end

  it "has a show page" do
    expect(page).to have_content "Comp1100"
  end

  it "does not mention assignments" do
    expect(page).to_not have_content "Wireworld"
  end

  it "does not mention groups" do
    expect(page).to_not have_content "Thursday A"
  end
end