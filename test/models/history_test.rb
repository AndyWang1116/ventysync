# == Schema Information
#
# Table name: histories
#
#  id         :integer          not null, primary key
#  sync_to    :string           not null
#  section    :string           not null
#  action     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  message    :jsonb            default("{}"), not null
#

require 'test_helper'

class HistoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
