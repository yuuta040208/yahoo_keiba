class Race < ApplicationRecord
  has_many :tanfuku_odds
  has_many :umaren_odds
  has_many :umatan_odds
  has_many :wide_odds
end
