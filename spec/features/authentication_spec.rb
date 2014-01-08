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
      fill_in 'Uni ID', :with => "u4989649"
      click_button "Log in"
    end

    it "logs in successfully" do
      expect(page).to have_content("Dolly O'Keefe")
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

  feature "signing in as a convenor" do
    before(:each) do
      visit new_sessions_url
      fill_in 'Uni ID', :with => "u2222222"
      click_button "Log in"
    end

    it "logs in successfully" do
      expect(page).to have_content("Hello Uwe Zimmer")
    end

    it "redirects to Courses page on successful login" do
      expect(page).to have_content("Courses")
      expect(page).to have_content("Comp1100 (Uwe Zimmer)")
    end

    it "knows you are a convenor" do
      expect(page).to have_content("You're a convenor!")
      expect(page).to_not have_content("You're an admin!")
    end

    it "lets you log out" do
      expect(page).to have_button("Log out")
    end

    it "logs out properly" do
      click_button("Log out")
      expect(page).to_not have_content("Uwe Zimmer")
    end
  end

end