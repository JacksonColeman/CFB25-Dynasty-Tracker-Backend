class User < ApplicationRecord
  has_secure_password  # This adds authentication methods for password management (e.g., password validation and hashing)

  has_many :dynasties, dependent: :destroy
  has_many :players, through: :dynasties, dependent: :destroy
  has_many :recruits, through: :dynasties, dependent: :destroy

  # Optional: Validations for email and username
  validates :email, presence: true, uniqueness: true, format: { 
    with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\z/, 
    message: "must be a valid email address"
  }  
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  def active_dynasty
    Dynasty.find_by(id: self.current_dynasty_id)
  end
end
