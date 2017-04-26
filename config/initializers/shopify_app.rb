ShopifyApp.configure do |config|
  config.api_key = "44840fbaa5a5f7490a2677c6c889cee4"
  config.secret = "998df49b50f5b49b6bb24f8b7bde7ed3"
  config.scope = "read_orders, write_orders, read_products, write_products, read_customers, write_customers"
  config.embedded_app = true
  config.webhooks = [
    {topic: 'orders/updated', address: 'https://81c77473.ngrok.io/webhooks/orders_updated', format: 'json'},
    {topic: 'orders/create', address: 'https://81c77473.ngrok.io/webhooks/orders_create', format: 'json'},
    {topic: 'products/update', address: 'https://81c77473.ngrok.io/webhooks/products_update', format: 'json'}
  ]
end
