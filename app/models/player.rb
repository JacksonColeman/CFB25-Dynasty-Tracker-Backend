class Player < ApplicationRecord
  # Associations
  belongs_to :dynasty

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :class_year, presence: true, inclusion: { in: %w[Freshman Sophomore Junior Senior Graduate], message: "%{value} is not a valid class year" }
  validates :position, presence: true
  validates :archetype, presence: true
  validates :overall, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :dev_trait, presence: true, inclusion: { in: %w[Normal Impact Star Elite], message: "%{value} is not a valid dev trait" }

  # Redshirt validation: Ensure that current_redshirt cannot be true if redshirted is false
  validates :redshirted, inclusion: { in: [true, false] }
  validates :current_redshirt, inclusion: { in: [true, false] }
  validate :current_redshirt_logic

  # Callbacks (optional, if needed)
  # You can add a callback to set the default values or enforce other logic before creating/updating a player

  def advance_class_year
    if current_redshirt
      # If the player is redshirting, set them to redshirted and disable redshirt status
      update(current_redshirt: false, redshirted: true)
    else
      # Advance the class year (freshman -> sophomore -> junior -> senior -> graduate)
      case class_year
      when 'Freshman'
        update(class_year: 'Sophomore')
      when 'Sophomore'
        update(class_year: 'Junior')
      when 'Junior'
        update(class_year: 'Senior')
      when 'Senior'
        update(class_year: 'Graduate')
      when 'Graduate'
        return true
      else
        # Handle unexpected class_year (optional, depending on your data)
        errors.add(:class_year, "Invalid class year")
        false # Indicate failure
      end
    end
  end

  private

  def current_redshirt_logic
    # Ensure that a player cannot have a current_redshirt if they have not been redshirted before
    if current_redshirt && redshirted
      errors.add(:current_redshirt, "Player has already been redshirted!")
    end
  end
end
