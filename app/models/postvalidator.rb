class PostValidator < ActiveModel::Validator

  validates_attachment_size :pic, :less_than => 5.megabytes
  validates_attachment_content_type :pic, :content_type => ['image/jpeg', 'image/png', 'image/gif']

  validate :validates_pic_or_post
  validates :content, :length => { :maximum => 2500 }

  pass_regex = /^\w+$/

  validates :password, :presence => true,
                       :length => { :maximum => 15 },
                       :format => { :with => pass_regex }

  def validates_pic_or_post
    errors.add(:Post, " must have text post or attachment.") if
    content == "<p></p>" and pic_file_name.blank? and media.blank?
  end

end