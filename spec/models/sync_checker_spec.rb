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

require 'rails_helper'

RSpec.describe SyncChecker, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
