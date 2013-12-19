class CoursesController < ApplicationController
  before_filter :require_logged_in

  def index
    @courses = Course.all
    render :index
  end
end
