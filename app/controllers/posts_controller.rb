class PostsController < ApplicationController

  before_filter :set_current_user
  
  def show
    @boards = Board.all
    @categories = Category.all
    @post = Post.find_by_slug(params[:post_id])
    @board = Board.find_by_slug(@post.board_abbreviation)
    if @post.title?
      @title = "| "+@board.title+" | "+@post.title
    else
      if @post.content?
        if @post.content.length < 31
          @title = "| "+@board.title+" | "+Sanitize.clean(@post.content)
        else
          @title = "| "+@board.title+" | "+Sanitize.clean(@post.content.first(30)+"...")
        end
      else
        @title = "| "+@board.title+" | Thread #"+@post.number.to_s
      end
    end
  end

  def create
    @post = Post.new(params[:post])
    @board = Board.find_by_slug(@post.board_abbreviation)
    @post = @board.posts.new(params[:post])
    @post.content = parse(@post.content, @board.abbreviation)
    if @board.pcaptcha? && verify_recaptcha(:model => @post) && @post.save
      post_save
    else
      if @board.pcaptcha?
        error
      else
        if @post.save
          post_save
        else
          error
        end
      end
    end
  end

  def destroy
    @post = Post.find_by_slug(params[:post_id])
    @board = Board.find_by_slug(@post.board_abbreviation)
    @password = cookies[:password]
    if current_user
      post_destroy
    else
      if @password == @post.password
        post_destroy
      else
        redirect_to '/'+@post.slug, :notice => 'You cannot delete this thread.'
      end
    end
  end
  
  def update_cache
    expire_fragment('thread_'+@post.slug)
    expire_fragment('full-thread_'+@post.slug)
  end

  def post_save
    @post.update_attribute(:updated_at, Time.now)
    cookies[:password] = { :value => @post.password, :expires => Time.now + 2600000}
    redirect_to @post
  end

  def post_destroy
    @post.destroy
    update_cache
    redirect_to '/'+@board.abbreviation, :notice => 'Thread was successfully deleted.'
  end

  def error
    render "err"
  end

end