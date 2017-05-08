# == Schema Information
#
# Table name: shops
#
#  id             :integer          not null, primary key
#  shopify_domain :string           not null
#  shopify_token  :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#

class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage
end
