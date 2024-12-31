class Recruit < ApplicationRecord
  belongs_to :dynasty

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :position, presence: true
  validates :archetype, presence: true
  validates :recruit_class, presence: true, inclusion: { in: [ "High School", "JUCO (FR)", "JUCO (SO)", "Transfer (FR)", "Transfer (SO)", "Transfer (JR)" ] }
  validates :recruiting_stage, presence: true, inclusion: { in: [ "Open", "Top 8", "Top 5", "Top 3", "Committed" ] }
  validates :visit_week, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :star_rating, presence: true, inclusion: { in: 1..5 }

  # validates :athlete, inclusion: { in: [ true, false ] }
  # validates :scouted, inclusion: { in: [ true, false ] }
  # validates :gem, inclusion: { in: [ true, false ] }
  # validates :bust, inclusion: { in: [ true, false ] }
  #

  def turn_into_player(params)
    overall = params[:overall]
    position = params[:position]
    dev_trait = params[:dev_trait]
    archetype = params[:archetype]
  # Convert recruit_class to class_year
  class_year = case recruit_class
  when "High School" then "Freshman"
  when "JUCO (FR)" then "Freshman"
  when "JUCO (SO)" then "Sophomore"
  when "Transfer (FR)" then "Sophomore"
  when "Transfer (SO)" then "Junior"
  when "Transfer (JR)" then "Senior"
  else "Unknown"  # Default value in case no match is found
  end

    Player.create!(
      first_name: first_name,
      last_name: last_name,
      position: position,
      archetype: archetype,
      overall: overall,
      dev_trait: dev_trait,
      class_year: class_year,  # Add the converted class_year
      redshirted: false,
      current_redshirt: false,
      dynasty: dynasty
    )
    destroy
  end
end
