module Paperclip
  class ConditionalConverter < Thumbnail
    def initialize(file, options = {}, attachment = nil)
      super(file, options, attachment)
      @format = :jpg if self.animated?
    end
  end
end