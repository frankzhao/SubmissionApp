require 'spec_helper'

feature "the sign in process" do
  it "has a log in page do" do
    visit new_sessions_url
    expect(page).to have_content("Log in")
    expect(page).to_not have_content("Log out")
  end

  feature "signing in as a student" do
    before(:each) do
      visit new_sessions_url
      fill_in 'Uni ID', :with => "u5192430"
      click_button "Log in"
    end

    it "logs in successfully" do
      expect(page).to have_content("Michele Hirthe")
    end

    it "redirects to Courses page on successful login" do
      expect(page).to have_content("Courses")
      expect(page).to have_content("Comp1100 (Uwe Zimmer)")
    end

    it "knows you're not a convenor" do
      expect(page).to_not have_content("You're a convenor!")
      expect(page).to_not have_content("You're an admin!")
    end

    it "lets you log out" do
      expect(page).to have_button("Log out")
    end
  end
end