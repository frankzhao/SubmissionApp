class AssignmentSubmissionsController < ApplicationController
  before_filter :require_logged_in

  def show
    @submission = AssignmentSubmission.find(params[:id], include: :submission_files)
    @assignment = @submission.assignment
    @comments = @submission.comments
    @relationship = @submission.relationship_to_user(current_user)

    current_user.notifications.where(:notable_type => "AssignmentSubmission",
                                     :notable_id => @submission.id).delete_all

    current_user.notifications.where(:notable_type => "Comment")
                              .includes(:notable)
                              .select { |s| s.notable.assignment_submission_id == @submission.id }
                              .map(&:delete)

    if @relationship
      render :show
    else
      flash[:errors] = ["You don't have permission to access that page"]
      redirect_to "/"
    end
  end

  def new
    @assignment = Assignment.find(params[:assignment_id])

    relationship = current_user.relationship_to_assignment(@assignment)
    #NOTE: this allows the user to be a staff member.
    unless relationship || current_user.is_admin
      flash[:errors] = ["You're not allowed to submit that assignment..."]
      redirect_to courses_url
      return
    end

    if relationship == :student && !@assignment.is_visible
      flash[:errors] = ["That assignment isn't visible yet."]
      redirect_to "/"
      return
    end

    unless @assignment.already_due(current_user)
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

  # Staff members are allowed to create assignments.

  # This method is very ugly, and I really should rewrite it. Sorry :(
  def create
    @assignment = Assignment.find(params[:assignment_id])

    unless current_user.relationship_to_assignment(@assignment) || current_user.is_admin
      flash[:errors] = ["You aren't enrolled in a course with that assignment."]
      redirect_to "/"
      return
    end

    if @assignment.already_due(current_user)
      flash[:errors] = ["Assignment is already due."]
      redirect_to assignment_url(@assignment)
      return
    end

    unless (@assignment.is_visible ||
          current_user.relationship_to_assignment(@assignment) == :staff ||
              current_user.is_convener_or_admin)
      flash[:errors] = ["Assignment is not visible yet."]
      redirect_to "/"
      return
    end

    @submission = AssignmentSubmission.new(params[:submission])
    @submission.assignment = Assignment.find(params[:assignment_id])
    @submission.user_id = current_user.id
    if @submission.save
      @submission.receive_submission
      if @assignment.submission_format == "zipfile"
        if (params[:upload] and params[:upload]["datafile"])
          @submission.save_data(params[:upload]["datafile"].read)
          begin
            @submission.zip_contents
          rescue => e
            valid = false
            flash[:errors] = ["That file couldn't be read as a zip file, with
              the following error:", e.to_s]
            render :new
            return
          else
            @submission.make_files_from_zip_contents
          end

        else
          flash[:errors] = ["Please select a file to upload."]
          render :new
          return
        end
      elsif @assignment.submission_format == "plaintext"
        @submission.make_file_from_body
      end

      redirect_to(assignment_assignment_submission_url(params[:assignment_id],@submission))
    else
      flash[:errors] = ["Assignment was not successfully saved"] + @submission.errors.full_messages
      render :new
    end
  end

  def destroy
    if current_user.is_admin_or_convener?
      @submission = AssignmentSubmission.find_by_id(params[:id])
      if @submission
        @submission.delete
        flash[:notifications] = ["Assignment submission #{@submission.id} for #{@submission.assignment.name} by #{@submission.user.name} was deleted"]
        redirect_to @submission.assignment
      else
        flash[:errors] = ["That assignment submission could not be found."]
        redirect_to "/"
      end
    else
      flash[:errors] = "You aren't allowed to do that."
      redirect_to @submission.assignment
    end
  end


  def get_zip
    @submission = AssignmentSubmission.find(params[:id])

    filename = @submission.pretty_file_name(current_user) + '.zip"'

    if @submission.permits?(current_user)
      response.headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      send_file(@submission.zip_path)
    else
      flash[:errors] = ["You don't have permission to access that page"]
      redirect_to "/"
    end
  end

  def finalize
    @submission = AssignmentSubmission.find(params[:assignment_submission_id])
    @relationship = @submission.relationship_to_user(current_user)
    if @relationship
      @submission.finalize!
      flash[:notifications] = ["Assignment submission finalized."]
      redirect_to :back
    else
      flash[:errors] = ["Permission denied"]
      logger.warn("Security warning: someone tried to finalize someone else's submission")
      redirect_to "/"
    end
  end
end
