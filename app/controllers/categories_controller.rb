class CategoriesController < ApplicationController

  before_filter :set_current_user
  load_and_authorize_resource

  def new
    @category = Category.new
    @title = "| New Category"
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @title = "| Edit Category"
    @category = Category.find(params[:id])
  end

  def create
    @category = Category.new(params[:category])

    respond_to do |format|
      if @category.save
        format.html { redirect_to(boards_url, :notice => 'Category was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(boards_url, :notice => 'Category was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @category = Category.find(params[:id])
    @category.destroy

    respond_to do |format|
      format.html { redirect_to(boards_url) }
    end
  end
end