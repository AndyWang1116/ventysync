# == Schema Information
#
# Table name: sync_checkers
#
#  id                         :integer          not null, primary key
#  last_new_product_synced    :datetime
#  last_edited_product_synced :datetime
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

FactoryGirl.define do
  factory :sync_checker do
    last_new_product_synced "2017-05-23 16:35:09"
    last_edited_product_synced "2017-05-23 16:35:09"
  end
end
