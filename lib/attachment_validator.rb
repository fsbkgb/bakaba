class AttachmentValidator < ActiveModel::Validator

  def validate(record)
    if record.pic_file_name
      pic_regex = /^image\/(?:jpeg|gif|png)$/
      record.errors[:base] << "Unsupported format." if record.pic_content_type.match(pic_regex).nil?
      record.errors[:base] << "Picture too big." unless record.pic_file_size < $img_maxsize.megabytes
    end
    record.errors[:base] << "Post must have text post or attachment." if record.content.blank? and record.pic_file_name.blank? and record.media.blank?
  end

end