# == Schema Information
#
# Table name: races
#
#  id         :bigint           not null, primary key
#  no         :string(255)
#  year       :integer
#  kind       :string(255)
#  direction  :string(255)
#  weather    :string(255)
#  condition  :string(255)
#  distance   :integer
#  prize      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Race < ApplicationRecord
  has_many :tanfuku_odds
  has_many :umaren_odds
  has_many :umatan_odds
  has_many :wide_odds
end
