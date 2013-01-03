class CommentsController < ApplicationController

  before_filter :set_current_user
  
  def create
    @post = Post.find params[:post_id]
    @comment = @post.comments.new(params[:comment]) 
    @board = Board.find(@post.board_abbreviation)
    if @board.ccaptcha? && verify_recaptcha(:model => @comment) && @comment.save
      comment_save
    else
      if @board.ccaptcha?
        error
      else
        if @comment.save
          comment_save
        else
          error
        end
      end
    end
  end

  def destroy
    @post = Post.find params[:post_id]
    @comment = @post.comments.find params[:comment_id]
    @password = cookies[:password]
    if current_user
      comment_destroy
    else
      if @password == @comment.password
        comment_destroy
      else
        redirect_to '/'+@post.slug, :notice => 'You cannot delete this post.'
      end
    end
  end
  
  def update_cache
    expire_fragment('thread_'+@post.slug)
    expire_fragment('full-thread_'+@post.slug)
  end

  def comment_save
    cookies[:password] = { :value => @comment.password, :expires => Time.now + 2600000}
    update_cache
    redirect_to @post
  end

  def comment_destroy
    @comment.destroy
    update_cache
    redirect_to '/'+@post.slug, :notice => 'Post was successfully deleted.'
  end

  def error
    render "err"
  end

end