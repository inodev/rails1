class Category < ActiveRecord::Base
  attr_accessible :name,:id
  has_many :posts
  default_scope :order => 'created_at DESC'
  paginates_per 5
end
