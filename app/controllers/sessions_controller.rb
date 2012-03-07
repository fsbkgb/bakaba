class SessionsController < ApplicationController
  def new
  end

  def create
#    if verify_recaptcha
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to root_url
      else
        flash.now.alert = "Invalid name or password"
        render "new"
      end
#    else
#      flash.now.alert = "Invalid captcha."
#      render 'new'
#    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
