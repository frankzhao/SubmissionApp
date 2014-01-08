require 'spec_helper'

feature "viewing courses" do
  before(:each) do
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
    click_on "Wireworld"
    expect(page).to have_content "cellular automata!"
  end
end

feature "viewing courses which you aren't in" do
  before(:each) do
    visit new_sessions_url
    fill_in 'Uni ID', :with => "u4957443"
    click_button "Log in"
    visit "/courses/1"
  end

  it "says you aren't enrolled" do
    expect(page).to have_content "Note that you aren't enrolled in this course--you'd see more if you were."
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