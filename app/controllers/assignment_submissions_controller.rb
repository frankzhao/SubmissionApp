require "zip"

class AssignmentSubmissionsController < ApplicationController
  before_filter :require_logged_in

  def show
    @submission = AssignmentSubmission.find(params[:id])
    @assignment = @submission.assignment
    @comments = @submission.comments
    @relationship = @submission.relationship_to_user(current_user)

    if @relationship
      render :show
    else
      flash[:errors] = ["You don't have permission to access that page"]
      redirect_to "/"
    end
  end

  # TODO: Should I have some sort of "log dodginess" functionality?
  def new
    @assignment = Assignment.find(params[:assignment_id])

    #NOTE: this allows the user to be a staff member.
    unless current_user.relationship_to_assignment(@assignment)
      flash[:errors] = ["You're not allowed to submit that assignment..."]
      redirect_to courses_url
    end


    unless @assignment.already_due
      if @assignment.submission_format == "plaintext"
        @submission = @assignment.submissions
                   .where(:user_id => current_user.id)
                   .order(:created_at)
                   .last
      end
      render :new
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
      if @submission.save
        if @assignment.submission_format == "zipfile"
          if (params[:upload] and params[:upload]["datafile"])
            @submission.save_data(params[:upload]["datafile"].read)
          else
            flash[:errors] = ["Please select a file to upload."]
            render :new
            return
          end
        end

        redirect_to(assignment_assignment_submission_url(params[:assignment_id],@submission))
      else
        flash[:errors] = @submission.errors.full_messages
        render :new
      end
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
      flash[:errors] = ["You don't have permission to access that page"]
      redirect_to "/"
    end
  end

end
