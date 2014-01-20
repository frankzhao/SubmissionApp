class AssignmentsController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_permission, :only => [:edit, :update, :destroy,
                                          :get_csv, :get_zipfile, :peer_review]
  before_filter :require_convener_or_admin, :only => [:new, :create]

  # Session IP lock

  def require_permission
    @assignment = Assignment.find(params[:id])
    unless @assignment.group_type.conveners.include? current_user
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
    @assignment.create_marking_scheme(eval(params[:marking_scheme]))
    if @assignment.save
      redirect_to @assignment
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :new
    end
  end

  #TODO: this permits all conveners
  def edit
    @assignment = Assignment.find(params[:id])
    render :edit
  end

  def update
    @assignment.update_attributes(params[:assignment])
    @assignment.replace_marking_scheme(eval(params[:marking_scheme]))
    if @assignment.save
      redirect_to @assignment
    else
      flash.now[:errors] = @assignment.errors.full_messages
      render :new
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
      @permitted_submissions = current_user.permitted_submissions(@assignment)
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


  # TODO: check whether this is idiomatic
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
