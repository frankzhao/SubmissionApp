class CommentsController < ApplicationController
  def create
    #TODO: check that the person is allowed to comment
    @comment = Comment.new(params[:comment])
    @comment.user = current_user
    @comment.assignment_submission = AssignmentSubmission.find(params[:assignment_submission_id])
    @comment.save!
    redirect_to(assignment_assignment_submission_url(params[:assignment_id],
                            params[:assignment_submission_id]))
  end
end
