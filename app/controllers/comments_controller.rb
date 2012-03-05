class CommentsController < ApplicationController

  before_filter :set_current_user
  
  def create
    @comment = Comment.new(params[:comment])
    @post = Post.find_by_slug(@comment.post_slug)
    @comment = @post.comments.new(params[:comment])
    @board = Board.find_by_slug(@post.board_abbreviation)
    @comment.content = parse(@comment.content, @board.abbreviation)
    if @board.ccaptcha? && verify_recaptcha(:model => @comment) && @comment.save
      cookies[:password] = { :value => @comment.password, :expires => Time.now + 2600000}
      expire_fragment('thread_'+@post.slug)
      expire_fragment('full-thread_'+@post.slug)
      redirect_to @post
    else
      if @board.ccaptcha?
        render "err"
      else
        if @comment.save
          cookies[:password] = { :value => @comment.password, :expires => Time.now + 2600000}
          expire_fragment('thread_'+@post.slug)
          expire_fragment('full-thread_'+@post.slug)
          redirect_to @post
        else
          render "err"
        end
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @post = Post.find_by_slug(@comment.post_slug)
    @password = cookies[:password]
    if current_user
      @comment.destroy
      redirect_to @post, :notice => 'Post was successfully deleted.'
    else
      if @password == @comment.password
        @comment.destroy
        redirect_to @post, :notice => 'Post was successfully deleted.'
      else
        redirect_to @post, :notice => 'You cannot delete this post.'
      end
    end
  end

end
