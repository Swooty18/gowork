class Order < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :proposals, dependent: :destroy
  default_scope -> { order(created_at: :desc) }

  validates :user_id, presence: true
  validates :category_id, presence: true
  validates :title, presence: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 5000 }
  validates :city, presence: true
  validates :price, presence: true, numericality: {message: 'є неправильним значенням' }
  validates_datetime :duedate, on_or_after: lambda { Time.current }

  def self.search_by(title_or_description, category_id, city, min_price, max_price)
    min_price = -1 if min_price.empty?
    max_price = 1_000_000_000 if max_price.empty?
    # where("category_id = '#{category_id}' AND 
    #   ((' ' || (LOWER(title) || ' ' LIKE '%#{title_or_description.downcase}%' OR '#{title_or_description}' IS NULL) OR 
    #   (' ' || (LOWER(description) || ' ' LIKE '%#{title_or_description.downcase}%' OR '#{title_or_description}' IS NULL)) AND 
    #   (' ' || (LOWER(city) || ' ' LIKE '%#{city.downcase}%' OR '#{city}' IS NULL) AND 
    #   price >= #{min_price} AND price <= #{max_price} ")

    where("category_id = '#{category_id}'")
  end
end
