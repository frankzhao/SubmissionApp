class SessionsController < ApplicationController
  def new
    render :new
  end

  def create
    p params
    @uni_id, password = params[:user][:uni_id], params[:user][:password]
    if authenticate(@uni_id, password)
      @user = User.find_by_uni_id(@uni_id[1..-1].to_i)
      if @user
        login! @user
        redirect_to "/"
      else
        flash[:errors] = ["Sorry, you haven't been signed up.
                        Complain to your lecturer :/"]
        render :new
      end
    else
      flash[:errors] = ["Incorrect username/password"]
      render :new
    end
  end

  def destroy
    if current_user
      current_user.reset_session_token!
      logout! current_user
    end
    redirect_to "sessions/new"
  end


  # Currently disabled
  def authenticate(uni_id, password)
    return true
    ApplicationHelper.ldap_authenticate(uni_id, password)
  end
end
