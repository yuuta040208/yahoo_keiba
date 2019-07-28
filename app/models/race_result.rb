# == Schema Information
#
# Table name: race_results
#
#  id         :bigint           not null, primary key
#  race_id    :bigint
#  umaban     :integer
#  result     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RaceResult < ApplicationRecord
  belongs_to :race
end
