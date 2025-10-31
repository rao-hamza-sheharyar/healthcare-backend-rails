class Doctor < ApplicationRecord
  belongs_to :user
  has_many :appointments, dependent: :destroy
  has_many :reviews, dependent: :destroy
  
  validates :specialization, presence: true
  validates :experience_years, numericality: { greater_than_or_equal_to: 0 }
  validates :rating, numericality: { in: 0.0..5.0 }
  
  # Update rating when new review is added
  after_save :update_rating_if_needed
  
  def update_rating
    if reviews.any?
      self.rating = reviews.average(:rating) || 0.0
      self.total_reviews = reviews.count
      save
    end
  end
  
  private
  
  def update_rating_if_needed
    # This will be called from review callbacks
  end
end


