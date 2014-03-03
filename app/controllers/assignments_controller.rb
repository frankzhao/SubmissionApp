class AssignmentsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_permission, :only => [:edit, :update, :destroy,
                                          :get_csv, :get_zipfile, :peer_review]
  before_filter :require_convener_or_admin, :only => [:new, :create]

  def require_permission
    @assignment = Assignment.find(params[:id])
    unless @assignment.group_type.conveners.include? current_user || current_user.is_admin
      flash[:errors] = ["You don't have permission to do that with assignments."]
      redirect_to @assignment
    end
  end

  def new
    @group_type_id = params[:group_type_id]
    @group_type = GroupType.find(params[:group_type_id])
    if @group_type.conveners.include? current_user
      @assignment = Assignment.new
      @assignment.group_type = @group_type
      render :new
    else
      flash[:errors] = ["You can't create assignments for that course."]
      redirect_to courses_url
    end
  end

  def create
    @assignment = Assignment.new(params[:assignment])
    if @assignment.save
      redirect_to @assignment
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :new
    end
  end

  def edit
    @assignment = Assignment.find(params[:id])
    render :edit
  end

  def update
    @assignment.update_attributes(params[:assignment])
    if @assignment.save
      redirect_to @assignment
    else
      flash[:errors] = @assignment.errors.full_messages
      redirect_to edit_assignment_url(@assignment)
    end
  end

  def show
    @assignment = Assignment.find(params[:id])
    @relation = current_user.relationship_to_assignment(@assignment)

    case @relation
    when :student
      @user_submissions = @assignment.submissions
                                     .where(:user_id => current_user.id)
                                     .order('created_at DESC')
      @permitted_submissions = current_user.permitted_submissions_for_assignment(@assignment)
      render :show_to_student
    when :staff

      @submissions = @assignment.relevant_submissions(current_user)

      render :show_to_staff
    when :convener
      @submissions = @assignment.relevant_submissions(current_user)
      render :show_to_staff
    end
  end

  def destroy
    @assignment.destroy
    flash[:notifications] = ["Assignment \"#{@assignment.name}\" successfully destroyed"]
    redirect_to "/"
  end

  def get_csv
    @assignment = Assignment.find(params[:id])
    render :text => @assignment.marks_csv
  end

  def get_zipfile
    @assignment.update_zip
    send_file(@assignment.zip_path)
  end

  def peer_review
    @assignment.start_peer_review
    redirect_to @assignment
  end
end
