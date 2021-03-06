class BoardsController < ApplicationController
  
  before_filter :set_current_user
  load_and_authorize_resource :find_by => :slug
  
  def index
    @title = "| Boards"
    @boards = Board.all
    @posts = Post.all
    @comments = Comment.all
    @categories = Category.all
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @categories = Category.all
    @board = Board.find params[:board_id]
    @posts = @board.posts.order_by([:updated_at, :DESCENDING]).page(params[:page]).per($threads_on_page)
    @title = "| "+@board.title
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def catalog
    @categories = Category.all
    @board = Board.find params[:board_id]
    @posts = @board.posts.order_by([:created_at, :DESCENDING]).page(params[:page]).per($threads_on_page*$visible_comments)
    @title = "catalog | "+@board.title
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @title = "| New Board"
    @board = Board.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @title = "| Edit Board"
    @board = Board.find params[:id]
  end

  def create
    @board = Board.new(params[:board])

    respond_to do |format|
      if @board.save
        format.html { redirect_to(boards_url, :notice => 'Board was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
    expire_page ("/index")
    expire_fragment("navbar")
  end

  def update
    @board = Board.find params[:board_id]

    respond_to do |format|
      if @board.update_attributes(params[:board])
        format.html { redirect_to(boards_url, :notice => 'Board was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
    update_cache
  end

  def destroy
    @board = Board.find params[:board_id]
    @board.destroy

    respond_to do |format|
      format.html { redirect_to(boards_url) }
    end
    update_cache
  end
  
  def update_cache
    expire_page ("/index")
    expire_fragment("navbar")
    expire_fragment('goback_to_'+@board.abbreviation)
  end
  
end