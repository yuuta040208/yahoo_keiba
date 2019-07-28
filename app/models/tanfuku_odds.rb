# == Schema Information
#
# Table name: tanfuku_odds
#
#  id         :bigint           not null, primary key
#  race_id    :bigint
#  umaban     :integer
#  tan        :float(24)
#  fuku       :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TanfukuOdds < ApplicationRecord
  belongs_to :race
end
