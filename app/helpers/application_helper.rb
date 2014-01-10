require "net-ldap"

module ApplicationHelper

  ###### These two functions are taken from GitHub. TODO: rewrite them so that
  # the user information works.

  # Returns _true_ if authentication is successful, and _false_ otherwise.
  def self.ldap_authenticate(uni_id, password)
    ldap = get_new_ldap()
    ldap.auth "uid=#{uni_id}, ou=people, o=anu.edu.au", password

    ldap.bind
  end

  # Get a new connection to the ANU LDAP server.
  def self.get_new_ldap()
    Net::LDAP.new(:host => "ldap.anu.edu.au",
                  :port => 636,
                  :encryption => :simple_tls)
  end

  def current_user
    @current_user ||= User.find_by_session_token(session[:session_token])
  end

  def login!(user)
    user.reset_session_token!
    session[:session_token] = user.session_token
  end

  def logout!(user)
    user.reset_session_token!
    session[:session_token] = nil
  end

  def require_logged_in
    unless current_user
      flash[:errors] = ["You have to be logged in to see that"]
      redirect_to new_sessions_url
    end
  end

  def require_convener_or_admin
    unless current_user.is_convener? || current_user.is_admin
      flash[:errors] = ["You have to be a convener or admin to see that"]
      redirect_to courses_url
    end
  end
end
