class CreateRaces < ActiveRecord::Migration[5.2]
  def change
    create_table :races do |t|
      t.string :no, index: { unique: true }
      t.integer :year
      t.string :kind
      t.string :direction
      t.string :weather
      t.string :condition
      t.integer :distance
      t.integer :prize

      t.timestamps
    end
  end
end
