class BoardsController < ApplicationController
  
  load_and_authorize_resource
  before_filter :set_current_user

  def index
  	@title = "| Boards"
    @boards = Board.all
    @posts = Post.all
    @comments = Comment.all
    @categories = Category.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @boards }
    end
  end

  def show
    @categories = Category.all
    @board = Board.find(params[:id])
    @posts = @board.posts.where(:board_id => @board.id).order_by([:bump, :DESCENDING]).page(params[:page]).per($threads_on_page)
    @title = "| "+@board.title
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @board }
    end
  end

  def new
  	@title = "| New Board"
    @board = Board.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @board }
    end
  end

  def edit
  	@title = "| Edit Board"
    @board = Board.find(params[:id])
  end

  def create
    @board = Board.new(params[:board])

    respond_to do |format|
      if @board.save
        format.html { redirect_to(boards_url, :notice => 'Board was successfully created.') }
        format.xml  { render :xml => @board, :status => :created, :location => @board }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @board.errors, :status => :unprocessable_entity }
      end
    end
    expire_page ("/index")
    expire_fragment("navbar")
  end

  def update
    @board = Board.find(params[:id])

    respond_to do |format|
      if @board.update_attributes(params[:board])
        format.html { redirect_to(boards_url, :notice => 'Board was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @board.errors, :status => :unprocessable_entity }
      end
    end
    expire_page ("/index")
    expire_fragment("navbar")
  end

  def destroy
    @board = Board.find(params[:id])
    @board.destroy

    respond_to do |format|
      format.html { redirect_to(boards_url) }
      format.xml  { head :ok }
    end
    expire_page ("/index")
    expire_fragment("navbar")
  end
end
