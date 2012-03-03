class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :settings
  helper_method :current_user
  
  def parse(content, board)
    content.strip!
    if content!=""
      content.gsub!('&', '&amp;')
      content.gsub!('<', '&lt;')
      content.gsub!('>', '&gt;')
    
      content.scan(/&gt;&gt;\d+/).first(8).each do |x|
        reply_number = x.to_s.match(/\d+/)[0]
        if Post.where(:board_abbreviation => board, :number => reply_number).length > 0
          post = Post.where(:board_abbreviation => board, :number => reply_number).first
          reply_found = true
        else
          if Comment.where(:board_abbreviation =>board, :number => reply_number).length > 0
            comment = Comment.where(:board_abbreviation => board, :number => reply_number).first
            post = Post.where(:slug => comment.post_slug).first
            reply_found = true
          end
        end
        if reply_found
          reply_link = '<a href="/posts/'+post.slug+'#'+reply_number+'"onclick="javascript:highlight('+"'_"+reply_number+"'"+', true);">&gt;&gt;'+reply_number+'</a>'
          content = content.gsub("&gt;&gt;"+reply_number, reply_link)
        end
      end

      content.scan(/&gt;&gt;\/[a-zA-Z]{1,3}\/\d+/).first(8).each do |x|
        reply_number = x.to_s.match(/\d+/)[0]
        board_abbr = x.to_s.match(/\/[a-zA-Z]{1,3}\//)[0].match(/[a-zA-Z]{1,3}/)[0]
        if Post.where(:board_abbreviation => board_abbr, :number => reply_number).length > 0
          post = Post.where(:board_abbreviation => board_abbr, :number => reply_number).first
          reply_found = true
        else
          if Comment.where(:board_abbreviation => board_abbr, :number => reply_number).length > 0
            comment = Comment.where(:board_abbreviation => board_abbr, :number => reply_number).first
            post = Post.where(:slug => comment.post_slug).first
            reply_found = true
          end
        end
        if reply_found
          reply_link = '<a href="/posts/'+post.slug+'#'+reply_number+'">&gt;&gt;'+"/"+board_abbr+"/"+reply_number+'</a>'
          content = content.gsub("&gt;&gt;/"+board_abbr+"/"+reply_number, reply_link)
        end
      end

#     content.gsub!(/\n?\[c\]\n*(.+?)\n*\[\/c\]/im, "<pre>\\1</pre>")
      content.gsub!(/^&gt;(.+)$/, "<span class='quote'>&gt;\\1</span><br />")
      content.scan(/https?:\/\/[\S]+/i).each do |x|
        link='<a href="'+x.to_s+'" rel="nofollow">'+x.to_s+'</a>'
        content = content.gsub(x.to_s, link)
      end
      content.gsub! /\r\n/, '<br />'
      content.gsub! /(<br \/>){2,}/, '<br /><br />'
      content="<p>"+content+"</p>"
    end
  end
      
  def settings
    $adm_tag = '## Admin ##'
    $mod_tag = '## Mod ##'
    $threads_on_page = 20
    $bumplimit = 500
    $visible_comments = 5
  end
    
  def set_current_user
    User.current = current_user
  end    
    
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url
  end
    
  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
end
