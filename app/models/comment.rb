class Comment

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  include Mongoid::Timestamps
  include PostStuff

  field :content
  field :media
  field :media_description
  field :number, :type => Integer
  field :created_at
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :post_slug
  field :board_abbreviation

  attr_accessible :content, :post_slug, :password, :show_id, :pic, :media

  index ({ number: 1 })

  embedded_in :post, :inverse_of => :comments

  has_mongoid_attached_file :pic, styles: lambda { |a| a.instance.check_file_type},
                                  :processors => [:conditional_converter],
                                  :path => ":rails_root/public/pic/:board/:style/:filename",
                                  :url  => "/pic/:board/:style/:filename"
                    
  validates_with AttachmentValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :bump

  def set_params
    post = Post.find(post_slug)
    board = Board.find(post.board_abbreviation)
    set_attr(board)
    self._slugs = [number.to_s]
    self.board_abbreviation = board.abbreviation
  end

  def bump
    post = Post.find(post_slug)
    if post.comments.size < $bumplimit
      post.touch unless post.pinned
    end
  end
  
  def check_file_type
    if is_image_type?
      {:small => "180x180>"}
    elsif is_video_type?
      {:small => { :geometry => "180x180>", :format => 'jpg', :time => 1, :processors => [:ffmpeg] }}
    else
      {}
    end
  end
  
  def is_image_type?
    pic_content_type =~ %r(image)
  end

  def is_video_type?
    pic_content_type =~ %r(video)
  end
  
end