class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name
      t.string :class_year
      t.string :position
      t.string :archetype
      t.integer :overall
      t.string :dev_trait
      t.boolean :redshirted
      t.boolean :current_redshirt
      t.references :dynasty, null: false, foreign_key: true

      t.timestamps
    end
  end
end
