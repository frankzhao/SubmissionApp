require 'spec_helper'

describe AssignmentSubmission do
  describe "methods" do
    describe "group" do
      it "identifies the user's group" do
        emily = User.create!(:name => "Emily", :uni_id => 32)
        comp4620 = Course.create!(:name => "Comp4620", :convener_id => 1)
        labs = GroupType.create!(:name => "Comp4620 labs",
                         :courses => [comp4620])
        tute = Group.create!(:name => "Wen's lab", :group_type_id => labs.id)
        wireworld = Assignment.create!(:name => "theory assignment",
                               :info => "this is very hard",
                               :group_type => labs,
                               :due_date => "2014-05-03 23:04:26",
                               :behavior_on_submission => '{"you fail": []}')
        submission = AssignmentSubmission.create(:user_id => emily.id,
                                                :assignment_id => wireworld.id)
        expect(submission.group).to eq(tute)
      end
    end
  end
end