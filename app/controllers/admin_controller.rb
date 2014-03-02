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

    render :log
  end
end