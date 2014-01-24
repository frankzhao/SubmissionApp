require "spec_helper"

feature "marks" do
  before(:each) do
    set_up_example_course
    submit_wireworld_as_user("u5555551")
  end

  counter = 1
  ["u2222222","u5192430"].each do |uni_id|
    feature "#{uni_id} can add marks" do
      feature "adding valid marks" do
        before(:each) do
          mark_submission(uni_id, counter)
        end

        ["u5555551", "u2222222", "u5192430"].each do |viewer_id|
          counter += 1
          it "lets #{viewer_id} see the mark" do
            sign_in viewer_id
            visit "/assignments/wireworld/assignment_submissions/1"
            expect(page).to have_content("Correctness: #{counter}/50")
          end
        end

        ["u2222222","u5192430"].each do |new_marker_id|
          it "lets #{new_marker_id} overwrite marks" do
            counter += 1
            mark_submission(new_marker_id, counter)
            sign_in uni_id
            visit "/assignments/wireworld/assignment_submissions/1"
            expect(page).to have_content("Correctness: #{counter}/50")
          end
        end
      end
    end

    [-5,63, "3.5"].each do |mark|
      it "can't add the invalid mark #{mark} as #{uni_id}" do
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