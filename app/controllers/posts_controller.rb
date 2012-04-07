class PostsController < ApplicationController

  before_filter :set_current_user
  
  def show
    @boards = Board.all
    @categories = Category.all
    @post = Post.find_by_slug(params[:id])
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
      cookies[:password] = { :value => @post.password, :expires => Time.now + 2600000}
      redirect_to @post
    else
      if @board.pcaptcha?
        render "err"
      else
        if @post.save
          cookies[:password] = { :value => @post.password, :expires => Time.now + 2600000}
          redirect_to @post
        else
          render "err"
        end
      end
    end
  end

  def destroy
    @post = Post.find_by_slug(params[:id])
    @board = Board.find_by_slug(@post.board_abbreviation)
    @password = cookies[:password]
    if current_user
      @post.destroy
      update_cache
      redirect_to board_path(@board), :notice => 'Post was successfully deleted.'
    else
      if @password == @post.password
        @post.destroy
        update_cache
        redirect_to board_path(@board), :notice => 'Post was successfully deleted.'
      else
        redirect_to post_path(@post), :notice => 'You cannot delete this post.'
      end
    end
  end
  
  def update_cache
    expire_fragment('thread_'+@post.slug)
    expire_fragment('full-thread_'+@post.slug)
  end

end