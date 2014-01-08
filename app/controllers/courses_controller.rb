class CoursesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convenor_or_admin, :except => [:show, :index]

  def new
    @course = Course.new
    render :new
  end

  def create
    render :text => params
  end

  # def create
  #   @course = Course.new(params[:course])
  #   unless current_user.is_admin
  #     @course.convenor = current_user
  #   end

  # end

  def index
    require_logged_in
    @user_courses = current_user.courses
    @other_courses = Course.all - @user_courses
    render :index
  end

  def show
    @course = Course.find(params[:id])
    @convenor = @course.convenor
    @staffs = @course.staff # I am aware that the plural of staff isn't staffs
    if current_user.courses.include?(@course)
      @students = @course.students
      @group_types = @course.group_types
      @assignments = @course.assignments.order("due_date ASC")
    end
    render :show
  end
end
