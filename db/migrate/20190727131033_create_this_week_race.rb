class CreateThisWeekRace < ActiveRecord::Migration[5.2]
  def change
    create_table :this_week_races do |t|
      t.string :date
      t.string :hold
      t.integer :no
      t.string :time
      t.string :name
      t.string :info
      t.string :distance

      t.timestamps
    end
  end
end
