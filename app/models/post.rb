class Post

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  include Mongoid::Timestamps
  include PostStuff

  field :title
  field :content
  field :media
  field :media_description
  field :number, :type => Integer
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :board_abbreviation
  field :post_slug
  field :pinned, :type => Boolean

  attr_accessible :title, :content, :board_abbreviation, :password, :show_id, :pic, :updated_at, :media

  belongs_to :board, :inverse_of => :posts
  embeds_many :comments

  index ({ updated_at: 1 })

  has_mongoid_attached_file :pic, styles: lambda { |a| a.instance.check_file_type},
                                  :processors => [:conditional_converter],
                                  :path => ":rails_root/public/pic/:board/:style/:filename",
                                  :url  => "/pic/:board/:style/:filename"

  validates :title, :length => { :maximum => 30 }
  validates_with AttachmentValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :check_posts_length

  def set_params
    board = Board.find(board_abbreviation)
    set_attr(board)
    self._slugs = [board.abbreviation+'-'+(number).to_s]
  end

  def check_posts_length
    board = Board.find(board_abbreviation)
    if Post.where(board_abbreviation: board.abbreviation).length > board.maxthreads
      post = Post.where(board_abbreviation: board.abbreviation).ascending(:updated_at).first
      post.destroy
    end
  end
  
  def check_file_type
    if is_image_type?
      {:small => "220x220>", :catalog => "100x100>"}
    elsif is_video_type?
      {:small => { :geometry => "220x220>", :format => 'jpg', :time => 1, :processors => [:ffmpeg] }, :catalog => { :geometry => "100x100>", :format => 'jpg', :time => 1, :processors => [:ffmpeg] }}
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