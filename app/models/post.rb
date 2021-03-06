class Post < ActiveRecord::Base
  attr_accessible :content, :title, :category_id

  has_many :comments
  has_many :categories

  default_scope :order => 'created_at ASC'
  paginates_per 4

  # 検索条件をラムダ式で追加
  scope :content_or_title_matches, lambda {|q|  
    where 'content like :q or title like :q', :q => "%#{q}%"  
  }

  attr_accessible :avatar
  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>" }
  validates :avatar, :presence => true
  validates :title, :presence => true
  validates :content, :presence => true,
                      :length => { :minimum => 5 }

end
