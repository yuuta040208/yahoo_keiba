class CreateUmarenOdds < ActiveRecord::Migration[5.2]
  def change
    create_table :umaren_odds do |t|
      t.references :race
      t.integer :first
      t.integer :second
      t.float :odds

      t.timestamps
    end
  end
end
