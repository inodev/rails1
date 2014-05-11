class Post < ActiveRecord::Base
  attr_accessible :content, :title

  has_many :comments

  default_scope :order => 'created_at DESC'
  paginates_per 5

  attr_accessible :avatar
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }

  validates :title, :presence => true
  validates :content, :presence => true,
                      :length => { :minimum => 5 }

end
