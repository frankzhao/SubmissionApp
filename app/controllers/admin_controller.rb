class AdminController < ApplicationController
  before_filter :require_logged_in
  before_filter :require_convener_or_admin

  def log
    request_text = `cat #{Rails.root.to_s}/log/production.log`

    @requests = request_text.split("\nStarted")

    render :log
  end

  def summary_log
    request_text = `cat #{Rails.root.to_s}/log/production.log`

    @requests = request_text.split("\nStarted")

    @requests.select! do |request|
      match = " GET \"/assets"
      request[0...match.length] != match
    end

    @requests.select! do |request|
      match = " GET \"/admin"
      request[0...match.length] != match
    end

    @requests = @requests[-100..-1]

    render :log
  end

  def database
    send_file(Rails.root.to_s+"/SubmissionApp_development")
  end

  def spoof_login
    login! User.find_by_uni_id(params[:id])
    redirect_to "/"
  end
end