class Comment

  include Mongoid::Document
  include Mongoid::Paperclip
  field :content
  field :number, :type => Integer
  field :created_at
  field :password
  field :phash
  field :show_id, :type => Boolean
  field :author
  field :post_slug
  field :board_abbreviation

  attr_accessible :content, :post_slug, :password, :show_id, :pic

  index :number

  referenced_in :post, :inverse_of => :comments

  has_mongoid_attached_file :pic, :styles => { :small => "180x180>" },
                                  :url  => "/pic/:board/:style/:filename"
  validates_attachment_size :pic, :less_than => 5.megabytes
  validates_attachment_content_type :pic, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  validate :validates_pic_or_post
  validates :content, :length => { :maximum => 2500 }

  pass_regex = /^\w+$/

  validates :password, :presence => true,
                       :length => { :maximum => 15 },
                       :format => { :with => pass_regex }

  before_post_process :rename_file
  before_create :set_params
  after_create :bump
  
  def validates_pic_or_post
    errors.add(:comment, " must have text post or picture!") if
    content.blank? && pic_file_name.blank?
  end

  def rename_file
    extension = File.extname(pic_file_name).gsub(/^\.+/, '')
    rnd = rand(1000).to_s
    time = Time.now.to_i
    self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
  end

  def set_params
    post = Post.find_by_name(self.post_slug)
    board = Board.find_by_slug(post.board_abbreviation)
    self.number = board.comments + 1
    board.update_attributes(:comments => board.comments + 1)
    self.board_abbreviation = board.abbreviation
    self.created_at = Time.now.strftime("%A %e %B %Y %H:%M:%S")
    if self.show_id == true
      if User.current
        self.author = User.current.role
      else
        self.phash = Digest::SHA2.hexdigest(self.password+post.name)[0, 30]
      end
    end
  end

  def bump
    post = Post.find_by_name(self.post_slug)
    if post.comments.size < $bumplimit
      post.update_attributes(:bump => Time.now)
    end
  end

end
