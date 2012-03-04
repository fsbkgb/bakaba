class UsersController < ApplicationController

  before_filter :set_current_user
  load_and_authorize_resource :find_by => :name
  
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path
    else
      render "new"
    end
  end

  def destroy
    @user = User.find_by_slug(params[:id])
    @user.destroy
    redirect_to users_path
  end

end
