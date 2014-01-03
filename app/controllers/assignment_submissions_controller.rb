class AssignmentSubmissionsController < ApplicationController
  before_filter :require_logged_in

  def show
    @submission = AssignmentSubmission.find(params[:id])
    @assignment = @submission.assignment
    @comments = @submission.comments

    if @submission.permits?(current_user)
      render :show
    else
      flash[:errors] = "You don't have permission to access that page"
      redirect_to "/"
    end
  end

  def new
    #TODO: require the user to be in this course

    @assignment = Assignment.find(params[:assignment_id])
    @submission = @assignment.submissions
                             .where(:user_id => current_user.id)
                             .order(:created_at)
                             .last
    render :new
  end

  def create
    @submission = AssignmentSubmission.new(params[:submission])
    @submission.assignment_id = params[:assignment_id]
    @submission.user_id = current_user.id
    @submission.save!
    redirect_to(assignment_assignment_submission_url(params[:assignment_id],@submission))
  end
end
