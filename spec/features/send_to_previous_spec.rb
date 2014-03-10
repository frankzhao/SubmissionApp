require "spec_helper"

feature "peer review cycles" do
  feature "using send_to_previous" do
    before(:each) do
      set_up_example_course
      prc = PeerReviewCycle.create!(:assignment_id => 1,
                       :distribution_scheme => "send_to_previous",
                       :shut_off_submission => false,
                       :anonymise => false)
      prc.activate!
    end

    it "initially doesn't have any permissions" do
      expect(PeerReviewCycle.last.submission_permissions.length).to eq(0)
    end

    feature "after a single student submits," do
      before(:each) do
        dolly = User.find_by_uni_id(5555551)
        AssignmentSubmission.create!(:user_id => dolly.id, :assignment_id => 1)
      end

      it "has no permissions" do
        expect(PeerReviewCycle.last.submission_permissions.length).to eq(0)
      end

      feature "after they finalize," do
        before(:each) do
          AssignmentSubmission.last.finalize!
        end

        it "has one permission" do
          expect(PeerReviewCycle.last.submission_permissions.length).to eq(1)
          expect(PeerReviewCycle.last.submission_permissions.last.user.name).to eq ("Uwe Zimmer")
        end

        feature "after the next guy submits," do
          before(:each) do
            brooks = User.find_by_uni_id(5555552)
            AssignmentSubmission.create!(:user_id => brooks.id, :assignment_id => 1)
          end

          it "still has 1 permission" do
            expect(PeerReviewCycle.last.submission_permissions.length).to eq(1)
          end

          feature "after the next guy finalises," do
            before(:each) do
              AssignmentSubmission.last.finalize!
            end

            it "should have the right permissions now" do
              expect(PeerReviewCycle.last.submission_permissions.length).to eq(2)
              p = SubmissionPermission.last
              expect(p.user.uni_id).to equal(5555551)
              expect(p.assignment_submission.user.uni_id).to equal(5555552)
            end

            feature "third guy" do
              before(:each) do
                daniel = User.find_by_uni_id(5555553)
                AssignmentSubmission.create!(:user_id => daniel.id,
                                        :assignment_id => 1)
                AssignmentSubmission.last.finalize!
              end

              it "should have the right permissions too" do
                expect(PeerReviewCycle.last.submission_permissions.length).to eq(3)
                p = SubmissionPermission.last
                expect(p.user.uni_id).to equal(5555552)
                expect(p.assignment_submission.user.uni_id).to equal(5555553)
              end
            end
          end
        end
      end
    end
  end
end