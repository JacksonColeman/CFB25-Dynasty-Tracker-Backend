class CreateRecruits < ActiveRecord::Migration[8.0]
  def change
    create_table :recruits do |t|
      t.string :first_name
      t.string :last_name
      t.string :position
      t.string :archetype
      t.string :recruit_class
      t.boolean :athlete
      t.boolean :scouted
      t.boolean :gem
      t.boolean :bust
      t.string :recruiting_stage
      t.integer :visit_week
      t.string :notes
      t.references :dynasty, null: false, foreign_key: true

      t.timestamps
    end
  end
end
