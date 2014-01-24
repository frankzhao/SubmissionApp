require 'spec_helper'

feature "submitting assignments" do
  before(:each) do
    dolly = User.create!(:name => "Dolly O'Keefe", :uni_id => 5555551)
    uwe = User.create!(:name => "Uwe Zimmer", :uni_id => 2222222)
    comp1100 = Course.create!(:name => "Comp1100", :convener_id => uwe.id)
    dolly.enroll_in_course!(comp1100)

    brooks = User.create!(:name => "Brooks Kris", :uni_id => 5555552)

    tute = GroupType.create!(:name => "Comp1100/1130 labs",
                         :courses => [comp1100])
    dolly.join_group!(tute)
    buck = User.create!(:name => "Buck Shlegeris", :uni_id => 5192430)
    buck.enroll_staff_in_course!(comp1100)
    buck_tute = tute.create_groups("Thursday A"=>[buck])

    tessa = User.create!(:name => "Tessa Bradbury", :uni_id => 5423452)

    wireworld = Assignment.create!(:name => "Wireworld",
                                   :info => "cellular automata!",
                                   :group_type_id => 1,
                                   :due_date => "2014-05-03 23:04:26")
    wireworld.add_marking_category!(:name => "Correctness",
                                    :description => "how wrong it is",
                                    :maximum_mark => 10)
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
      sign_in "u5555551"
      visit "/assignments/wireworld/assignment_submissions/new"
      expect(page).to have_content("New assignment submission for Wireworld")
      fill_in "submission[body]", :with => "main = undefined"
      click_button "Submit!"
      sign_out
    end

    it "is visible to the person who submitted it" do
      sign_in "u5555551"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("Submission for Wireworld")
      expect(page).to have_content("main = undefined")
    end

    it "is visible to the tutor of the person who submitted it" do
      sign_in "u5192430"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("Submission for Wireworld")
      expect(page).to have_content("main = undefined")
    end

    it "is not visible to other tutors" do
      sign_in "u5423452"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("You don't have permission to access that page")
      expect(page).to_not have_content("Submission for Wireworld")
      expect(page).to_not have_content("main = undefined")
    end

    it "is not visible to other people" do
      sign_in "u5555552"
      visit "/assignments/wireworld/assignment_submissions/1"
      expect(page).to have_content("You don't have permission to access that page")
      expect(page).to_not have_content("Submission for Wireworld")
      expect(page).to_not have_content("main = undefined")
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

    feature "marks" do
      counter = 1
      ["u2222222","u5192430"].each do |uni_id|
        feature "#{uni_id} can add marks" do
          feature "adding valid marks" do
            ["u5555551", "u2222222", "u5192430"].each do |viewer_id|
              counter += 1
              it "lets #{viewer_id} see it" do
                sign_in uni_id
                visit "/assignments/wireworld/assignment_submissions/1"
                within(:css, "div#comment-") do
                  fill_in "comment[body]", :with => "look at #{uni_id} commenting"
                  fill_in "mark_Correctness", :with => "#{counter}"
                  click_on "Post comment"
                end
                sign_out

                sign_in viewer_id
                visit "/assignments/wireworld/assignment_submissions/1"
                expect(page).to have_content("Correctness: #{counter}/10")
              end
            end
          end
        end

        [-5,23].each do |mark|
          it "can't add the invalid mark #{mark}" do
            sign_in uni_id
            visit "/assignments/wireworld/assignment_submissions/1"
            within(:css, "div#comment-") do
              fill_in "comment[body]", :with => "look at #{uni_id} commenting"
              fill_in "mark_Correctness", :with => "-5"
              click_on "Post comment"
            end
            expect(page).to have_content("You can't award negative marks.")
            expect(page).to_not have_content("-5")
          end
        end
      end
    end
  end
end