class CreateRaceResult < ActiveRecord::Migration[5.2]
  def change
    create_table :race_results do |t|
      t.references :race
      t.integer :umaban
      t.integer :result

      t.timestamps
    end
  end
end
