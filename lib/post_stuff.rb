module PostStuff

  extend ActiveSupport::Concern

  included do
    validates :content, :length => { :maximum => 2500 }

    pass_regex = /^\w+$/

    validates :password, :presence => true,
                         :length => { :within => 5..15 },
                         :format => { :with => pass_regex }
  end

  module InstanceMethods
    def set_attr (board)
      self.content = parse(content, board)
      self.media = parse_media(media) if media?
      self.pic.destroy if pic? and media?
      self.number = board.comments + 1 
      self.post_slug = board.abbreviation+'-'+(number).to_s if self.class.name == "Post"
      board.update_attribute(:comments, board.comments + 1)
      if self.show_id == true
        if User.current
          self.author = User.current.role
        else
          self.phash = Digest::SHA2.hexdigest(password+post_slug)[0, 30]
        end
      end
    end

    def parse(content, board)
      content.strip!
      unless content.nil?

        content.gsub!('&', '&amp;')
        content.gsub!('<', '&lt;')
        content.gsub!('>', '&gt;')

        code_blocks = []
        content.gsub!(/``(.+?)``/m) do |block|
          code_blocks.push($1)
          "<>"
        end

        links = []
        content.gsub!(/(http(s?):\/\/.+)/i) do |block2|
          links.push($1)
          "&&&"
        end

        content.gsub!(/(\*\*)(.+?)\1/, '<b>\2</b>')
        content.gsub!(/(\/\/)(.+?)\1/, '<i>\2</i>')
        content.gsub!(/(\-\-)(.+?)\1/, '<del>\2</del>')
        content.gsub!(/(\%\%)(.+?)\1/, '<span class="spoiler">\2</span>')
        
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
            reply_link = '<a href="'+post.slug+'#'+reply_number+'" id="popup_'+(board.comments + 1).to_s+'_'+reply_number+'" onclick="javascript:highlight('+"'_"+reply_number+"'"+', true);">>>'+reply_number+'</a>'
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
        content.gsub!(/\r\n/, '<br />')
        content.gsub!(/(<br \/>){2,}/, '<br /><br />')
        code_blocks.each{ |block| content.sub!(/<>/){ '<pre><code>'+block+'</code></pre>' } }
        links.each{ |block2| content.sub!(/&&&/){ block2 } }
        content
      end
    end
  

    def parse_media(media)
      youtube_regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]{11})(\&\S+)?(\S)*/
      vimeo_regex = /https?:\/\/(www.)?vimeo\.com\/([0-9]*)/
      vocaroo_regex = /http:\/\/vocaroo\.com\/i\/([A-Za-z0-9]{12})/
      pastebin_regex = /http:\/\/pastebin\.com\/([A-Za-z0-9]{8})/

      if media.match(youtube_regex) or media.match(vimeo_regex) or media.match(vocaroo_regex) or media.match(pastebin_regex)
        media.gsub(youtube_regex) do
          media = '<iframe src=\"http://www.youtube.com/embed/'+$3+'\" width=\"410\" height=\"270\"></iframe>' unless $3.nil?
        end
        media.gsub(vimeo_regex) do
          media = '<iframe src=\"http://player.vimeo.com/video/'+$2+'\" width=\"410\" height=\"270\"></iframe>' unless $2.nil?
        end
        media.gsub(vocaroo_regex) do
          media = '<embed src=\"http://vocaroo.com/player.swf?playMediaID='+$1+'&amp;autoplay=0\" width=\"148\" height=\"44\" wmode=\"transparent\" type=\"application/x-shockwave-flash\"/><br /><small><a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_mp3\">MP3</a>, <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_ogg\">Ogg</a>, <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_flac\">FLAC</a>, or <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_wav\">WAV</a>.</small>' unless $1.nil?
        end
        media.gsub(pastebin_regex) do
          media = '<iframe src=\"http://pastebin.com/embed_iframe.php?i='+$1+'\" style=\"width:600px;height:300px\"></iframe>' unless $1.nil?
        end
      else
        media = nil
      end
    end

    def rename_file
      extension = File.extname(pic_file_name).gsub(/^\.+/, '')
      rnd = rand(1000).to_s
      time = Time.now.to_i
      self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
    end
  end
end