class User < ApplicationRecord
  has_secure_password  # This adds authentication methods for password management (e.g., password validation and hashing)

  has_many :dynasties, dependent: :destroy
  has_many :players, through: :dynasties, dependent: :destroy
  has_many :recruits, through: :dynasties, dependent: :destroy

  # Optional: Validations for email and username
  validates :email, presence: true, uniqueness: true
  validates :username, presence: true, uniqueness: true

  def active_dynasty
    Dynasty.find_by(id: self.current_dynasty_id)
  end
end
