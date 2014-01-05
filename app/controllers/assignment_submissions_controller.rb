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
    if @assignment.due_date > Time.now
      @submission = @assignment.submissions
                         .where(:user_id => current_user.id)
                         .order(:created_at)
                         .last
      if @assignment.submission_format == "plaintext"
        render :new_plaintext
      elsif @assignment.submission_format = "zipfile"
        render :new_zipfile
      end
    else
      flash[:errors] = ["Assignment is already due."]
      redirect_to assignment_url(@assignment)
    end
  end

  def create
    # TODO: require the user to be in the course
    @assignment = Assignment.find(params[:assignment_id])

    if @assignment.due_date > Time.now
      if @assignment.submission_type == "zipfile"
        @submission.upload = params[:upload]["datafile"].read
        @submission.save_data
      end
      @submission = AssignmentSubmission.new(params[:submission])
      @submission.assignment_id = params[:assignment_id]
      @submission.user_id = current_user.id
      @submission.save!
      redirect_to(assignment_assignment_submission_url(params[:assignment_id],@submission))
    else
      flash[:errors] = ["Assignment is already due."]
      redirect_to assignment_url(@assignment)
    end
  end


end
