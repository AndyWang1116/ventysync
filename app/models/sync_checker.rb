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

class SyncChecker < ActiveRecord::Base

  after_create :set_last_synced

  private

  def set_last_synced
    update_columns(last_new_product_synced: Time.zone.now, last_edited_product_synced: Time.zone.now )
  end
end
