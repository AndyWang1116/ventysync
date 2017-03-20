Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    callback_url: "https://ec2-54-254-250-138.ap-southeast-1.compute.amazonaws.com/auth/shopify/callback",
    scope: ShopifyApp.configuration.scope
end
