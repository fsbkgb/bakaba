class Board

  include Mongoid::Document

  field :category
  field :title
  field :abbreviation
  field :maxthreads, :type => Integer, :default => 100
  field :comments, :type => Integer, :default => 0
  field :hidden, :type => Boolean
  field :pcaptcha, :type => Boolean
  field :ccaptcha, :type => Boolean

  index :abbreviation, :unique => true

  referenced_in :category, :inverse_of => :boards
  references_many :posts, :dependent => :destroy

  acts_as_sluggable :generate_from => :abbreviation

  validates :title,  :presence => true,
                     :length => { :maximum => 30 }
  validates :abbreviation,  :presence => true,
                            :length => { :maximum => 3 },
                            :uniqueness => { :case_sensitive => false }

end
