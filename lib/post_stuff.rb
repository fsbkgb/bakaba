module PostStuff

  extend ActiveSupport::Concern

  included do
    validates :content, :length => { :maximum => 2500 }

    pass_regex = /^\w+$/

    validates :password, :presence => true,
                         :length => { :within => 5..15 },
                         :format => { :with => pass_regex }
  end

  module InstanceMethods
    def set_attr (board)
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
    end

    def rename_file
      extension = File.extname(pic_file_name).gsub(/^\.+/, '')
      rnd = rand(1000).to_s
      time = Time.now.to_i
      self.pic.instance_write(:file_name, "#{time}#{rnd}.#{extension}")
    end
  end

end