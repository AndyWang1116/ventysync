class SyncToShopifyService
  def initialize(params)
    @token = params[:access_token]
    @sync_checker = SyncChecker.last
  end

  def sync_products
    sync_new_products
    sync_edit_products
  end

  def sync_new_products
    # OPTIMIZE: 目前只抓取一頁也就是假設更新率時間內(2mins)新產品不會超過25個
    products = get_data_from_venty("products.json?sort=created_at&page=1")
    n = 0
    products.each do |product|
      if need_sync_new?(product)
      n += 1
      original_data = get_data_from_venty("products/#{product["id"]}.json")
      data = convert_data(original_data)
      leave_a_record(sync_to: 'shopify', section: 'new product', action: 'conver_data', message: data)
      response = send_data_to_shopify(data)
      leave_a_record(sync_to: 'shopify', section: 'new product', action: 'send_data', message: response)
      product_id = product['id']
      venty_reponse = save_3rd_party_id(product_id, original_data, response)
      leave_a_record(sync_to: 'venty', section: 'new product', action: 'save_3rd_party', message: venty_reponse)
      end
    end
    if n > 0
      @sync_checker.update(last_new_product_synced: products.first['created_at']) 
      puts "#{n} new product(s) have been synced."
    else
      puts "No new products."
    end
  end

  def sync_edited_products
    # TODO:
    # 不僅要檢查product也要一併檢查variants 有沒有被更新過
    # 如果只有更新3rd_party_id, 就不用更新
    products = CheckSyncSevice.new(access_token: @token, target: "venty", check: "new_products")
    products.each do |product|
      original_data = get_data_from_venty("products/#{product["id"]}.json")
      data = convert_data(original_data)
    end
  end

  def test(path)
    product = get_data_from_venty(path)
    data = convert_data(product)
    response = send_data_to_shopify(data)
    save_3rd_party_id(17, product, response)
  end

  def convert_data(product)
    # 設定product的options
    options = []
    if product['properties']
      product['properties'].each do |k,v|
      option = { name: k }
      options.push option
      end
    end

    # 設定product的variants
    variants_data = []
    variants = product['variants']
    variants.each do |v|
      variant = {
        "title": v['name'],
        "barcode": v['bardcore'],
        "sku": v['sku'],
        "inventory_quantity": v['stock_on_hand'],
        "price": "#{v['retail_price']}",
        "taxable": v['taxable'],
        "inventory_policy": "continue",
        "inventory_management": "shopify",
        "requires_shipping": true,
        "weight": v['weight'].to_f,
        "weight_unit": "kg",
        "grams": v['weight'].to_f * 1000
      }
      if v['properties']
        properties_count = v['properties'].length || 0
          properties_count.times do |i|
          values = v['properties'].values
          variant["option#{i + 1}"] = values[i]
        end
      end
      variants_data.push variant
    end
    # 一次連同variants一起更新data
    product_json = {
    product: {
    "title": product['name'],
    "body_html": product['description'],
    "vendor": product['default_supplier_name'],
    "product_type": product['product_type_name'],
    "published": false,
    "tags": product['tag_string'],
    "options": options,
    "variants": variants_data
      }
    }
  end

  def send_data_to_shopify(data)
    shop = Shop.find_by(shopify_domain: shopify_domain)
    shopify_headers = {"Content-Type"=>"application/json"}
    HTTParty.post(
      "https://#{api_key}:#{shop.shopify_token}@#{shopify_domain}/admin/products.json",
      body: data.to_json,
      headers: shopify_headers
    )
  end

  def save_3rd_party_id(product_id, original_data, response)
    variants = []
    original_data['variants'].each do |v|
      third_party_id = response['product']['variants']
      .select { |x| x['title'].delete(' ') == v['name'] || x['title'] == 'Default Title' }
      .first['id']
      variant = { id: v['id'], third_party_id: third_party_id } 
      variants.push variant
    end
    data = {
      product: {
        third_party_id: response['product']['id'],
        variants_attributes: variants
      }
    }
    HTTParty.patch("#{venty_url("products/#{product_id}.json")}", body: data, headers: headers)
  end 

  def get_data_from_venty(path)
    HTTParty.get(venty_url(path), headers: headers )
  end

  def need_sync_new?(product)
    product['created_at'] > @sync_checker.last_new_product_synced
  end

  def need_sync_edited?(product)
    product['updated_at'] > @sync_checker.last_edited_product_synced
  end

  def leave_a_record(args)
    History.create(sync_to: args[:sync_to], section: args[:section], action: args[:action], message: args[:message])
  end

  def headers
    {"Authorization"=>"#{@token}"}
  end

  def venty_url(path)
    "http://b1828022.ngrok.io/#{path}"
  end

  def shopify_domain
    "ll-staging.myshopify.com"
  end

  def api_key
    ShopifyApp.configuration.api_key
  end
end