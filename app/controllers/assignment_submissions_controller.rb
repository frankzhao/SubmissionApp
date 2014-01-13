require "zip"

class AssignmentSubmissionsController < ApplicationController
  before_filter :require_logged_in

  def show
    @submission = AssignmentSubmission.find(params[:id])
    @assignment = @submission.assignment
    @comments = @submission.comments

    if @submission.permits?(current_user)
      if @assignment.submission_format == "zipfile"
        @files = @submission.zip_contents
      end

      render :show
    else
      flash[:errors] = "You don't have permission to access that page"
      redirect_to "/"
    end
  end

  def new
    #TODO: require the user to be in this course
    @assignment = Assignment.find(params[:assignment_id])
    if @assignment.already_due
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

    unless @assignment.already_due
      @submission = AssignmentSubmission.new(params[:submission])
      @submission.assignment_id = params[:assignment_id]
      @submission.user_id = current_user.id
      @submission.save!

      if @assignment.submission_format == "zipfile"
        @submission.save_data(params[:upload]["datafile"].read)
      end

      redirect_to(assignment_assignment_submission_url(params[:assignment_id],@submission))
    else
      flash[:errors] = ["Assignment is already due."]
      redirect_to assignment_url(@assignment)
    end
  end


  def get_zip
    @submission = AssignmentSubmission.find(params[:id])

    if @submission.permits?(current_user)
      send_file(@submission.zip_path)
    else
      flash[:errors] = "You don't have permission to access that page"
      redirect_to "/"
    end
  end

end
