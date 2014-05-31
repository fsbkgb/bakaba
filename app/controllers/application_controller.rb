class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :settings
  helper_method :current_user
        
  def settings
    $adm_tag = '## Admin ##'
    $mod_tag = '## Mod ##'
    $threads_on_page = 8
    $bumplimit = 500
    $img_maxsize = 4 #in megabytes
    $visible_comments = 5 #show last 5 posts of the thread on a board page
    $version = "0.6.2"
  end
    
  def set_current_user
    User.current = current_user
  end    
    
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url
  end
    
  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
end