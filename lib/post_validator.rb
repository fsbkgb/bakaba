class PostValidator < ActiveModel::Validator

  def validate(record)
    pass_regex = /^\w{6,15}$/
    if record.pic_file_name
      pic_regex = /^image\/(?:jpeg|gif|png)$/
      record.errors[:base] << "Unsupported format." if record.pic_content_type.match(pic_regex).nil?
      record.errors[:base] << "Picture too big." unless record.pic_file_size < 5.megabytes
    end
    record.errors[:base] << "Incorrect password." if record.password.match(pass_regex).nil?
    record.errors[:base] << "Post too long." unless record.content.length < 2500
    record.errors[:base] << "Post must have text post or attachment." if record.content == "<p></p>" and record.pic_file_name.blank? and record.media.blank?
  end

end