# == Schema Information
#
# Table name: wide_odds
#
#  id         :bigint           not null, primary key
#  race_id    :bigint
#  first      :integer
#  second     :integer
#  odds       :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ThisWeekRace < ApplicationRecord
end
