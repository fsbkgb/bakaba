class Category
  include Mongoid::Document
  field :name
  references_many :boards
end
