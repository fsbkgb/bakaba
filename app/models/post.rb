class Post

  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Slug

  field :title
  field :content
  field :number, :type => Integer
  field :created_at
  field :bump, :type => DateTime
  field :slug
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :board_abbreviation

  attr_accessible :title, :content, :board_abbreviation, :password, :show_id, :bump, :pic

  index :bump

  referenced_in :board, :inverse_of => :posts
  references_many :comments, :dependent => :destroy

  slug :slug

  has_mongoid_attached_file :pic, :styles => { :small => "220x220>" },
                                  :url  => "/pic/:board/:style/:filename"

  validates_attachment_size :pic, :less_than => 5.megabytes
  validates_attachment_content_type :pic, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  validate :validates_pic_or_post
  validates :content,  :length => { :maximum => 2500 }
  validates :title, :length => { :maximum => 30 }

  pass_regex = /^\w+$/

  validates :password, :presence => true,
                       :length => { :maximum => 15 },
                       :format => { :with => pass_regex }

  before_post_process :rename_file
  before_create :set_params
  after_create :check_posts_length
  
  def validates_pic_or_post
    errors.add(:post, "Post must have text post or picture!") if
    content.blank? && pic_file_name.blank?
  end

  def rename_file
    extension = File.extname(pic_file_name).gsub(/^\.+/, '')
    rnd = rand(1000).to_s
    time = Time.now.to_i
    self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
  end

  def set_params
    self.bump = Time.now
    board = Board.find_by_slug(self.board_abbreviation)
    self.number = board.comments + 1
    self.slug = board.abbreviation+'-'+(self.number).to_s
    board.update_attributes(:comments => board.comments + 1)
    self.created_at = Time.now.strftime("%A %e %B %Y %H:%M:%S")
    if self.show_id == true
      if User.current
        self.author = User.current.role
      else
        self.phash = Digest::SHA2.hexdigest(self.password+self.slug)[0, 30]
      end
    end
  end

  def check_posts_length
    board = Board.find_by_slug(self.board_abbreviation)
    if Post.all(:conditions => {:board_abbreviation => board.abbreviation}).length > board.maxthreads
      post = Post.all(:conditions => {:board_abbreviation => board.abbreviation}).descending(:bump).last
    post.destroy
    end
  end

end
