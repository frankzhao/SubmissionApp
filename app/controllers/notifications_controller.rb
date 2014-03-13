class NotificationsController < ApplicationController
  before_filter :require_logged_in

  def destroy
    notification = Notification.find(params[:id])
    if current_user == notification.user || current_user.is_admin
      notification.destroy
    else
      flash[:errors] = ["permission denied"]
    end
    redirect_to :back
  end

  def index
    render :json => current_user.notifications
  end
end
