class Dynasty < ApplicationRecord
  belongs_to :user
  has_many :players, dependent: :destroy

  VALID_YEARS = (2024..2054).to_a.freeze

  validates :dynasty_name, presence: true, uniqueness: { scope: :user_id }
  validates :school_name, presence: true
  validates :year, presence: true, inclusion: { in: VALID_YEARS }
end
