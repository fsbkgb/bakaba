class AttachmentValidator < ActiveModel::Validator
    
  def rasparseeley
    uri = URI.parse(@source)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.use_ssl = true  
    resp = http.request(request)
    data = resp.body
    @result = JSON.parse(data)
  end

  def validate(record)
    if record.pic_file_name
      pic_regex = /^video\/(?:webm)$|^image\/(?:jpeg|gif|png)$/
      record.errors[:base] << "Unsupported format." if record.pic_content_type.match(pic_regex).nil?
      record.errors[:base] << "Picture too big." unless record.pic_file_size < $img_maxsize.megabytes
    end
    if record.media
      youtube_regex = /https?:\/\/(www.)?(youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/watch\?feature=player_embedded&v=)([A-Za-z0-9_-]{11})(\&\S+)?(\S)*/
      vimeo_regex = /https?:\/\/(www.)?vimeo\.com\/([0-9]*)/
      vocaroo_regex = /http:\/\/vocaroo\.com\/i\/([A-Za-z0-9]{12})/

      if record.media.match(youtube_regex) or record.media.match(vimeo_regex) or record.media.match(vocaroo_regex)
        record.media.gsub(youtube_regex) do
          record.media = '<iframe src=\"http://www.youtube.com/embed/'+$3+'\" width=\"410\" height=\"270\"></iframe>' unless $3.nil?	  
	  @source = 'https://www.googleapis.com/youtube/v3/videos?part=snippet&id='+$3+'&key='{YOUR_API_KEY} #https://developers.google.com/youtube/registering_an_application#Create_API_Keys
          rasparseeley
          title = @result["items"][0]["snippet"]["title"]
          record.media_description = "Youtube video: "+title
        end
        record.media.gsub(vimeo_regex) do
          record.media = '<iframe src=\"http://player.vimeo.com/video/'+$2+'\" width=\"410\" height=\"270\"></iframe>' unless $2.nil?	  
          @source = 'https://vimeo.com/api/v2/video/'+$2+'.json'
          rasparseeley
          title = @result[0]["title"]
          record.media_description = "Vimeo video: "+title
        end
        record.media.gsub(vocaroo_regex) do
          record.media = '<embed src=\"http://vocaroo.com/player.swf?playMediaID='+$1+'&amp;autoplay=0\" width=\"148\" height=\"44\" wmode=\"transparent\" type=\"application/x-shockwave-flash\"/><br /><small><a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_mp3\">MP3</a>, <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_ogg\">Ogg</a>, <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_flac\">FLAC</a>, or <a href=\"http://vocaroo.com/media_command.php?media='+$1+'&amp;command=download_wav\">WAV</a>.</small>' unless $1.nil?
          record.media_description = "Vocaroo voice message"
        end
      else
        record.media = ""
      end
    end
    record.errors[:base] << "Post must have text post or attachment." if record.content.blank? and record.pic_file_name.blank? and record.media.blank?
  end

end
