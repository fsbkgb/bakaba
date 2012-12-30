class Post

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug

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
  validates_with PostValidator

  before_post_process :rename_file
  before_create :set_params
  after_create :check_posts_length

  def rename_file
    extension = File.extname(pic_file_name).gsub(/^\.+/, '')
    rnd = rand(1000).to_s
    time = Time.now.to_i
    self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
  end

  def set_params
    board = Board.find_by_slug(self.board_abbreviation)
    self.number = board.comments + 1
    board.update_attribute(:comments, board.comments + 1)
    self.created_at = Time.now.strftime("%A %e %B %Y %H:%M:%S")
    if self.show_id == true
      if User.current
        self.author = User.current.role
      else
        self.phash = Digest::SHA2.hexdigest(self.password+self.slug)[0, 30]
      end
    end
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