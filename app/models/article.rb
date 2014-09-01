class Article < ActiveRecord::Base
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :body, presence: true

  def to_param
    slug
  end
end
