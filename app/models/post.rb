class Post

  include Mongoid::Document
  include Mongoid::Paperclip
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

  acts_as_sluggable :generate_from => :slug

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
  before_create :set_params, :assign_html, :reflinks
  after_create :check_posts_length
  def validates_pic_or_post
    errors.add(:post, "Post must have text post or picture!") if
    content.blank? && pic_file_name.blank?
  end

  def assign_html
    self.content = RDiscount.new(self.content, :autolink, :filter_html, :filter_styles, :no_image).to_html
  end

  def rename_file
    extension = File.extname(pic_file_name).gsub(/^\.+/, '')
    rnd = rand(1000).to_s
    time = Time.now.to_i
    self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
  end

  def set_params
    self.bump = Time.now
    board = Board.find(self.board_abbreviation)
    self.number = board.comments + 1
    self.slug = board.abbreviation+'-'+(self.number).to_s
    board.update_attributes(:comments => board.comments + 1)
    self.created_at = Time.now.strftime("%A %e %B %Y %H:%M:%S")
    if self.show_id == true
      if User.current
        self.author = User.current.role
      else
        self.phash = encrypt(self.password)
      end
    end
  end

  def reflinks
    self.content.scan(/to\d+/).first(8).each do |x|
      reply_number = x.to_s.match(/\d+/)[0]
      if Post.where(:board_abbreviation => self.board_abbreviation, :number => reply_number).length > 0
        post = Post.where(:board_abbreviation => self.board_abbreviation, :number => reply_number).first
      reply_found = true
      else
        if Comment.where(:board_abbreviation => self.board_abbreviation, :number => reply_number).length > 0
          comment = Comment.where(:board_abbreviation => self.board_abbreviation, :number => reply_number).first
          post = Post.where(:slug => comment.post_slug).first
        reply_found = true
        end
      end
      if reply_found
        reply_link = '<a href="/posts/'+post.slug+'#'+reply_number+'">&gt;&gt;'+reply_number+'</a>'
        self.content = self.content.gsub("to"+reply_number, reply_link)
      else
        self.content = self.content.gsub("to"+reply_number, ">>"+reply_number)
      end
    end

    self.content.scan(/to\/[a-zA-Z]{1,3}\/\d+/).first(8).each do |x|
      reply_number = x.to_s.match(/\d+/)[0]
      board_abbr = x.to_s.match(/\/[a-zA-Z]{1,3}\//)[0].match(/[a-zA-Z]{1,3}/)[0]
      if Post.where(:board_abbreviation => board_abbr, :number => reply_number).length > 0
        post = Post.where(:board_abbreviation => board_abbr, :number => reply_number).first
      reply_found = true
      else
        if Comment.where(:board_abbreviation => board_abbr, :number => reply_number).length > 0
          comment = Comment.where(:board_abbreviation => board_abbr, :number => reply_number).first
          post = Post.where(:slug => comment.post_slug).first
        reply_found = true
        end
      end
      if reply_found
        reply_link = '<a href="/posts/'+post.slug+'#'+reply_number+'">&gt;&gt;'+"/"+board_abbr+"/"+reply_number+'</a>'
        self.content = self.content.gsub("to/"+board_abbr+"/"+reply_number, reply_link)
      else
        self.content = self.content.gsub("to/"+board_abbr+"/"+reply_number, ">>"+"/"+board_abbr+"/"+reply_number)
      end
    end
  end

  def encrypt(string)
    Digest::SHA2.hexdigest(string)[0, 30]
  end

  def check_posts_length
    board = Board.find(self.board_abbreviation)
    if Post.find(:conditions => {:board_abbreviation => board.abbreviation}).length > board.maxthreads
      post = Post.find(:conditions => {:board_abbreviation => board.abbreviation}).descending(:bump).last
    post.destroy
    end
  end

end
