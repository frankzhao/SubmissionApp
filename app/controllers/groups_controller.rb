class GroupsController < ApplicationController
  def show
    @group = Group.find(params[:id])
    @group_type = @group.group_type
    @users = @group.students
    @staff = @group.staff
    render :show
  end
end
