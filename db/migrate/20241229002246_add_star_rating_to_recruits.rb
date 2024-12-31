class AddStarRatingToRecruits < ActiveRecord::Migration[8.0]
  def change
    add_column :recruits, :star_rating, :integer
  end
end
