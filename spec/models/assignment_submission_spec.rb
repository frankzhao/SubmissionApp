require 'spec_helper'

describe AssignmentSubmission do
  describe "methods:" do
    describe "group" do
      it "gives nil for a group if there isn't a group" do
        emily = User.create!(:name => "Emily", :uni_id => 32)
        comp4620 = Course.create!(:name => "Comp4620", :convener_id => 1)
        labs = GroupType.create!(:name => "Comp4620 labs",
                         :courses => [comp4620])


        wireworld = Assignment.create!(assignment_hash("theory"))
        submission = AssignmentSubmission.create(:user_id => emily.id,
                                                :assignment_id => wireworld.id)
        expect(submission.group).to eq(nil)
      end

      it "identifies the user's group" do
        emily = User.create!(:name => "Emily", :uni_id => 32)
        comp4620 = Course.create!(:name => "Comp4620", :convener_id => 1)
        labs = GroupType.create!(:name => "Comp4620 labs",
                         :courses => [comp4620])


        wireworld = Assignment.create!(assignment_hash("theory"))
        submission = AssignmentSubmission.create(:user_id => emily.id,
                                                :assignment_id => wireworld.id)

       # expect(submission.group).to eq(nil)

        tute = Group.create!(:name => "Wen's lab", :group_type_id => labs.id)
        emily.join_group!(tute)

        expect(submission.group).to eq(tute)
      end
    end

    describe "self.uncommented" do
      before(:each) do
        emily = User.create!(:name => "Emily", :uni_id => 32)
        flo = User.create!(:name => "Flo", :uni_id => 3534)

        comp4620 = Course.create!(:name => "Comp4620", :convener_id => 1)
        labs = GroupType.create!(:name => "Comp4620 labs",
                                 :courses => [comp4620])

        wireworld = Assignment.create!(assignment_hash("whatever"))
        submission = AssignmentSubmission.create(:user_id => emily.id,
                                                :assignment_id => wireworld.id)
        SubmissionPermission.create!(:user_id => flo.id, :assignment_submission_id => submission.id)
      end

      it "includes non commented submissions" do
        flo = User.find_by_name("Flo")
        submission = AssignmentSubmission.first
        expect(flo.permitted_submissions.uncommented(flo)).to eq([submission])
        expect(flo.uncommented_submissions).to eq([submission])
      end

      it "doesn't include commented submissions" do
        flo = User.find_by_name("Flo")
        submission = AssignmentSubmission.first
        Comment.create!(:assignment_submission_id => 1, :user_id => flo.id,
                    :body => "whatever, good job I guess")
        expect(flo.permitted_submissions.uncommented(flo)).to eq([])
        expect(flo.uncommented_submissions).to eq([])
      end

    end
  end
end