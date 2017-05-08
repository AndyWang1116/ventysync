# == Schema Information
#
# Table name: histories
#
#  id         :integer          not null, primary key
#  sync_to    :string           not null
#  setion     :string           not null
#  action     :string           not null
#  message    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class History < ActiveRecord::Base
end
