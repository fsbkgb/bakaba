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
    @users = User.all
    if @user.role == 'adm' && @users.where(:role => 'adm').size > 0
      redirect_to users_path, :notice => 'Admin already exist'
    else
      if @user.save
        redirect_to users_path
      else
        render "new"
      end
    end
  end

  def destroy
    @user = User.find params[:id]
    if @user.role == 'adm'
      redirect_to users_path, :notice => 'No!'
    else  
      @user.destroy
      redirect_to users_path
    end
  end

  def show
  end

end
