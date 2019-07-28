# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_07_27_131033) do

  create_table "race_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "race_id"
    t.integer "umaban"
    t.integer "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_race_results_on_race_id"
  end

  create_table "races", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "no"
    t.integer "year"
    t.string "kind"
    t.string "direction"
    t.string "weather"
    t.string "condition"
    t.integer "distance"
    t.integer "prize"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["no"], name: "index_races_on_no", unique: true
  end

  create_table "tanfuku_odds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "race_id"
    t.integer "umaban"
    t.float "tan"
    t.float "fuku"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_tanfuku_odds_on_race_id"
  end

  create_table "this_week_races", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "date"
    t.string "hold"
    t.integer "no"
    t.string "time"
    t.string "name"
    t.string "info"
    t.string "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "umaren_odds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "race_id"
    t.integer "first"
    t.integer "second"
    t.float "odds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_umaren_odds_on_race_id"
  end

  create_table "umatan_odds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "race_id"
    t.integer "first"
    t.integer "second"
    t.float "odds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_umatan_odds_on_race_id"
  end

  create_table "wide_odds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "race_id"
    t.integer "first"
    t.integer "second"
    t.float "odds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_wide_odds_on_race_id"
  end

end
