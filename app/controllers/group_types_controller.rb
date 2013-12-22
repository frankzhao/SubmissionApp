class GroupTypesController < ApplicationController
  def show
    @group_type = GroupType.find(params[:id])
    @courses = @group_type.courses

    render :show
  end
end