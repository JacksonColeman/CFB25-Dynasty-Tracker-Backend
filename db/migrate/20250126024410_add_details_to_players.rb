class AddDetailsToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :height, :integer
    add_column :players, :weight, :integer
    add_column :players, :skill_caps, :integer
    add_column :players, :hometown, :string
    add_column :players, :home_state, :string
  end
end
