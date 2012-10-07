class ApplicationController < ActionController::Base
  
  protect_from_forgery
  
  before_filter :settings
  helper_method :current_user
  
  def parse(content, board)
    content.strip!
    unless content.nil?
      content.gsub!('&', '&amp;')
      content.gsub!('<', '&lt;')
      content.gsub!('>', '&gt;')
    
      content.scan(/&gt;&gt;\d+/).first(8).each do |x|
        reply_number = x.to_s.match(/\d+/)[0]
        if board.posts.where(:number => reply_number).length > 0
          post = board.posts.where(:number => reply_number).first
          reply_found = true
        else
          board.posts.each do |p|
            if p.comments.where(:number => reply_number).length > 0
              post = p
              reply_found = true
            end
          end
        end
        if reply_found
          reply_link = '<a href="'+post.slug+'#'+reply_number+'" onclick="javascript:highlight('+"'_"+reply_number+"'"+', true);">&gt;&gt;'+reply_number+'</a>'
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
          Board.where(:abbreviation => board_abbr).first.posts.each do |p|
            if p.comments.where(:number => reply_number).length > 0
              post = p
              reply_found = true
            end
          end
        end
        if reply_found
          reply_link = '<a href="'+post.slug+'#'+reply_number+'">&gt;&gt;'+"/"+board_abbr+"/"+reply_number+'</a>'
          content = content.gsub("&gt;&gt;/"+board_abbr+"/"+reply_number, reply_link)
        end
      end

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

  def parse_media(media)
    youtube_regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]{11})(\&\S+)?(\S)*/
    vimeo_regex = /https?:\/\/(www.)?vimeo\.com\/([0-9]*)/
    vocaroo_regex = /http:\/\/vocaroo\.com\/i\/([A-Za-z0-9]{12})/

    if media.match(youtube_regex) or media.match(vimeo_regex) or media.match(vocaroo_regex)
      media.gsub(youtube_regex) do
        media = '<iframe width="410" height="270" src="//www.youtube.com/embed/'+$3+'"></iframe>' unless $3.nil?
      end
      media.gsub(vimeo_regex) do
        media = '<iframe src="//player.vimeo.com/video/'+$2+'" width="410" height="270"></iframe>' unless $2.nil?
      end
      media.gsub(vocaroo_regex) do
        media = '<div class="vocaroo"><embed src="http://vocaroo.com/player.swf?playMediaID='+$1+'&amp;autoplay=0" width="148" height="44" wmode="transparent" type="application/x-shockwave-flash"/><br /><small><a href="http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_mp3">MP3</a>, <a href="http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_ogg">Ogg</a>, <a href="http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_flac">FLAC</a>, or <a href="http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_wav">WAV</a>.</small></div>' unless $1.nil?
      end
    else
      media = ''
    end
  end
      
  def settings
    $adm_tag = '## Admin ##'
    $mod_tag = '## Mod ##'
    $threads_on_page = 8
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