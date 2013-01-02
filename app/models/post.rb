class Post

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  include Mongoid::Timestamps
  include PostStuff

  field :title
  field :content
  field :media
  field :number, :type => Integer
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :board_abbreviation
  field :post_slug

  attr_accessible :title, :content, :board_abbreviation, :password, :show_id, :pic, :updated_at, :media

  belongs_to :board, :inverse_of => :posts
  embeds_many :comments

  index ({ updated_at: 1 })

  has_mongoid_attached_file :pic, :styles => { :small => $OP_thumb },
                                  :path => ":rails_root/public/pic/:board/:style/:filename",
                                  :url  => "/pic/:board/:style/:filename"

  validates :title, :length => { :maximum => 30 }
  validates_with AttachmentValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :check_posts_length

  def set_params
    board = Board.find(self.board_abbreviation)
    set_attr(board)
    self._slugs = [board.abbreviation+'-'+(self.number).to_s]
  end

  def check_posts_length
    board = Board.find(self.board_abbreviation)
    if Post.where(board_abbreviation: board.abbreviation).length > board.maxthreads
      post = Post.where(board_abbreviation: board.abbreviation).ascending(:updated_at).first
    post.destroy
    end
  end

end