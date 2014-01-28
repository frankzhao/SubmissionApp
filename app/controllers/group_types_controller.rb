class GroupTypesController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convener_or_admin, :only => [:new, :create, :index]

  def show
    @group_type = GroupType.find(params[:id])
    @courses = @group_type.courses

    render :show
  end

  def new
    @group_type = GroupType.new
    render :new
  end

  def create
    @group_type = GroupType.new
    @group_type.name = params[:group_type][:name]

    ActiveRecord::Base.transaction do
      if @group_type.save
        params[:group_type][:courses].try(:each) do |id|
          GroupCourseMembership.create!(:group_type_id => @group_type.id, :course_id => id)
        end
        redirect_to group_type_url(@group_type)
      else
        flash.now[:errors] = @group_type.errors.full_messages
        render :new
      end
    end
  end
end