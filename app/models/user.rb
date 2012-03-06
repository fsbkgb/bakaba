class User
  include Mongoid::Document
  field :name
  field :role
  field :password
    
  cattr_accessor :current_user
  
  validates :name,  :presence => true,
                    :length => { :maximum => 30 },
                    :uniqueness => { :case_sensitive => false }
  validates :role,  :presence => true
  validates :password,  :presence => true,
                        :length => { :within => 6..40 }
                        
  def self.authenticate(name, password)
    user = find(:conditions => {:name => name}).first
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
