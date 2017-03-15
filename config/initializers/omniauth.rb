Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shopify,
    ShopifyApp.configuration.api_key,
    ShopifyApp.configuration.secret,
    callback_url: "https://07a43f01.ngrok.io/auth/shopify/callback",
    scope: ShopifyApp.configuration.scope
end
