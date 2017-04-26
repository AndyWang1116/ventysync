Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    callback_url: ENV['CALLBACK_URL'],
    scope: ShopifyApp.configuration.scope
end
