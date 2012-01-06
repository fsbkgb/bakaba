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
  before_create :set_params, :assign_html
  after_create :bump
  def validates_pic_or_post
    errors.add(:comment, " must have text post or picture!") if
    content.blank? && pic_file_name.blank?
  end

  def assign_html
    self.content.gsub!('&', '&amp;')
    self.content.gsub!('<', '&lt;')
    self.content.gsub!('>', '&gt;')
    reflinks
    self.content.gsub!(/^&gt;(.+)$/, "<span class='quote'>&gt;\\1</span><br />")
    self.content.gsub!(/\n?\[c\]\n*(.+?)\n*\[\/c\]/im, "<pre>\\1</pre>")
    self.content.scan(/https?:\/\/[\S]+/i).each do |x|
      link='<a href="'+x.to_s+'" rel="nofollow">'+x.to_s+'</a>'
      self.content = self.content.gsub(x.to_s, link)
    end
    self.content.gsub! /\r\n/, '<br />'
    self.content.gsub! /(<br \/>){2,}/, '<br /><br />'
    self.content="<p>"+self.content+"</p>"
  end

  def rename_file
    extension = File.extname(pic_file_name).gsub(/^\.+/, '')
    rnd = rand(1000).to_s
    time = Time.now.to_i
    self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
  end

  def reflinks
    self.content.scan(/&gt;&gt;\d+/).first(8).each do |x|
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
        reply_link = '<a href="/posts/'+post.slug+'#'+reply_number+'"onclick="javascript:highlight('+"'_"+reply_number+"'"+', true);">&gt;&gt;'+reply_number+'</a>'
        self.content = self.content.gsub("&gt;&gt;"+reply_number, reply_link)
      else
        self.content = self.content.gsub("&gt;&gt;"+reply_number, "&gt;&gt;"+reply_number)
      end
    end

    self.content.scan(/&gt;&gt;\/[a-zA-Z]{1,3}\/\d+/).first(8).each do |x|
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
        self.content = self.content.gsub("&gt;&gt;/"+board_abbr+"/"+reply_number, reply_link)
      else
        self.content = self.content.gsub("&gt;&gt;/"+board_abbr+"/"+reply_number, "&gt;&gt;"+"/"+board_abbr+"/"+reply_number)
      end
    end
  end

  def set_params
    post = Post.find(self.post_slug)
    board = Board.find(post.board_abbreviation)
    self.number = board.comments + 1
    board.update_attributes(:comments => board.comments + 1)
    self.board_abbreviation = board.abbreviation
    self.created_at = Time.now.strftime("%A %e %B %Y %H:%M:%S")
    if self.show_id == true
      if User.current
        self.author = User.current.role
      else
        self.phash = encrypt(self.password)
      end
    end
  end

  def encrypt(string)
    Digest::SHA2.hexdigest(string)[0, 30]
  end

  def bump
    post = Post.find(self.post_slug)
    if post.comments.size < $bumplimit
      post.update_attributes(:bump => Time.now)
    end
  end

end
