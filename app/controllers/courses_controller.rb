class CoursesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convener_or_admin, :except => [:show, :index]

  def new
    @course = Course.new
    render :new
  end

  def create
    @course = Course.new(params[:course])
    unless current_user.is_admin
      @course.convener = current_user
    end

    # TODO: make these two in a transaction, deal with invalid code
    @course.save!
    @course.add_students_by_csv(params[:students_csv])
    flash[:notifications] =
          ["Course #{@course.name} created with #{@course.students.length} students."]
    redirect_to @course
  end

  def destroy
    @course = Course.find(params[:id])
    if @course.nil?
      flash[:errors] = ["The course you just tried to delete doesn't exist."]
    elsif @course.admin_or_convener?(current_user)
      @course.destroy
      flash[:notifications] = ["Course #{@course.name} destroyed."]
      redirect_to courses_url
    else
      flash[:errors] = ["You can't delete that course, and you shouldn't have that url..."]
      redirect_to course_url(@course)
    end
  end

  def index
    require_logged_in
    @user_courses = current_user.courses
    @other_courses = Course.all - @user_courses
    render :index
  end

  def show
    @course = Course.find(params[:id])

    if @course.nil?
      flash[:errors] = ["Looks like you went looking for a course that doesn't exist."]
    end

    @convener = @course.convener
    @staffs = @course.staff # Yes, I am aware that the plural of staff isn't staffs
    if current_user.courses.include?(@course)
      @students = @course.students
      @group_types = @course.group_types
      @assignments = @course.assignments.order("due_date ASC")
    end
    render :show
  end
end
