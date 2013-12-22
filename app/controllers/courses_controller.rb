class CoursesController < ApplicationController
  before_filter :require_logged_in

  def index
    @courses = Course.all
    render :index
  end

  def show
    @course = Course.find(params[:id])
    @convenor = @course.convenor
    @students = @course.students
    @staffs = @course.staff # I am aware that the plural of staff isn't staffs
    @group_types = @course.group_types
    render :show
  end
end
