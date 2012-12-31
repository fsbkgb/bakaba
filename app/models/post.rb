class Post

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug
  include PostStuff

  field :title
  field :content
  field :media
  field :number, :type => Integer
  field :created_at
  field :slug
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :board_abbreviation

  attr_accessible :title, :content, :board_abbreviation, :password, :show_id, :pic, :updated_at, :media

  referenced_in :board, :inverse_of => :posts
  embeds_many :comments

  index :updated_at
  slug :slug

  has_mongoid_attached_file :pic, :styles => { :small => "220x220>" },
                                  :url  => "/pic/:board/:style/:filename"

  validates :title, :length => { :maximum => 30 }
  validates_with AttachmentValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :check_posts_length

  def set_params
    board = Board.find_by_slug(self.board_abbreviation)
    set_attr(board)
    self.slug = board.abbreviation+'-'+(self.number).to_s
  end

  def check_posts_length
    board = Board.find_by_slug(self.board_abbreviation)
    if Post.all(:conditions => {:board_abbreviation => board.abbreviation}).length > board.maxthreads
      post = Post.all(:conditions => {:board_abbreviation => board.abbreviation}).descending(:updated_at).last
    post.destroy
    end
  end

end