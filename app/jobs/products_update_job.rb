class ProductsUpdateJob < ActiveJob::Base
  def perform(shop_domain:, webhook:)
    shop = Shop.find_by(shopify_domain: shop_domain)
    shop.with_shopify_session do
      # variants = webhook[:variants]
      # variants.each do |variant|
      #   variant_id = variant[:id]
      #   price = variant[:price].to_f

        # ShopifyAPI::Variant.new({
        #   id: variant_id,
        #   price: price + 1
        # }).save
      end
  end
end
