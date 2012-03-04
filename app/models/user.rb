class User
  include Mongoid::Document
  include Mongoid::Slug
  field :name
  field :role
  field :password

  attr_accessible :name, :role, :password

  cattr_accessor :current_user

  slug :name

  validates :name,  :presence => true,
                    :length => { :maximum => 30 },
                    :uniqueness => { :case_sensitive => false }
  validates :role,  :presence => true
  validates :password,  :presence => true,
                        :length => { :within => 6..40 }
  def self.authenticate(name, password)
    user = User.find_by_slug(name)
    if user && user.password == password
    user
    else
      nil
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

end
