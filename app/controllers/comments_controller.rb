class CommentsController < ApplicationController

  load_and_authorize_resource
  before_filter :set_current_user
  def create
    @comment = Comment.new(params[:comment])
    @post = Post.find(@comment.post_slug)
    @comment = @post.comments.new(params[:comment])
    @board = Board.find(@post.board_abbreviation)
    if @board.ccaptcha? && verify_recaptcha(:model => @comment) && @comment.save
      cookies[:password] = { :value => @comment.password, :expires => Time.now + 2600000}
      redirect_to @post
    else
      if @board.ccaptcha?
        render "err"
      else
        if @comment.save
          cookies[:password] = { :value => @comment.password, :expires => Time.now + 2600000}
          redirect_to @post
        else
          render "err"
        end
      end
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @post = Post.find(@comment.post_slug)
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
