class CreateTanfukuOdds < ActiveRecord::Migration[5.2]
  def change
    create_table :tanfuku_odds do |t|
      t.references :race
      t.integer :umaban
      t.float :tan
      t.float :fuku

      t.timestamps
    end
  end
end
