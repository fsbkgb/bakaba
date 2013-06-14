class Comment

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  include Mongoid::Timestamps
  include PostStuff

  field :content
  field :media
  field :media_thumb
  field :number, :type => Integer
  field :created_at
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :post_slug
  field :board_abbreviation

  attr_accessible :content, :post_slug, :password, :show_id, :pic, :media, :media_thumb

  index ({ number: 1 })

  embedded_in :post, :inverse_of => :comments

  has_mongoid_attached_file :pic, :styles => { :small => "180x180>" },
                                  :path => ":rails_root/public/pic/:board/:style/:filename",
                                  :url  => "/pic/:board/:style/:filename"
                                  
  validates_with AttachmentValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :bump

  def set_params
    post = Post.find(self.post_slug)
    board = Board.find(post.board_abbreviation)
    set_attr(board)
    self._slugs = [self.number.to_s]
    self.board_abbreviation = board.abbreviation
  end

  def bump
    post = Post.find(self.post_slug)
    if post.comments.size < $bumplimit
      post.touch
    end
  end

end