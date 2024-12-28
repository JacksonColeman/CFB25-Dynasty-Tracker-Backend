class CreateDynasties < ActiveRecord::Migration[8.0]
  def change
    create_table :dynasties do |t|
      t.string :dynasty_name
      t.string :school_name
      t.integer :year
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
