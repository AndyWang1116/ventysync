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
    new_products = check_new(products)
    if new_products.present?
      new_products.each do |product|
        original_data = get_data_from_venty("products/#{product[:id]}.json")
        data = convert_new_data(original_data)
        leave_a_record(sync_to: 'shopify', section: 'new product', action: 'convert_data', message: data)
        response = send_new_data(data)
        leave_a_record(sync_to: 'shopify', section: 'new product', action: 'send_data', message: response)
        venty_response = save_3rd_party_id(product[:id], original_data, response)
        leave_a_record(sync_to: 'venty', section: 'new product', action: 'save_3rd_party', message: venty_response)
      end
      @sync_checker.update(last_new_product_synced: products.first[:created_at]) 
      puts "#{new_products.count} new product(s) have been synced."
    else
      puts "No new products."
    end
  end

  def sync_edited_products
    # TODO:
    # 不僅要檢查product也要一併檢查variants 有沒有被更新過
    # 如果只有更新3rd_party_id, 就不用更新
    products = get_data_from_venty("products.json?sort=updated_at&page=1")
    edited_products = check_edited(products)
    if edited_products.present?
      edited_products.each do |product|
        original_data = get_data_from_venty("products/#{product[:id]}.json")
        data = convert_edited_data(original_data)
        leave_a_record(sync_to: 'shopify', section: 'edited product', action: 'convert_data', message: data)
        response = send_edited_data(data, path: "#{original_data[:third_party_id]}.json" )
        leave_a_record(sync_to: 'shopify', section: 'edited product', action: 'send_data', message: response)
        venty_response = save_3rd_party_id(product[:id], original_data, response)
        leave_a_record(sync_to: 'venty', section: 'new product', action: 'save_3rd_party', message: venty_response)
      end
      @sync_checker.update(last_edited_product_synced: products.first[:updated_at])
      puts "#{edited_products.count} edited product(s) have been synced."
    else
      puts "No edited products."
    end
  end

  def test
    original_data = get_data_from_venty("products/21.json")
    venty_response = save_3rd_party_id(21, original_data, response)
    data = convert_new_data(original_data)
    response = send_new_data(data)
  end

  def check_new(products)
    products
      .select { |p| p[:created_at] > @sync_checker.last_new_product_synced }
      .map { |h| h.slice(:id) }
  end

  def check_edited(products)
    products
      .select { |p| p[:updated_at] > @sync_checker.last_edited_product_synced }
      .map { |h| h.slice(:id) }
  end

  def convert_new_data(product)
    # 設定product的options
    options = []
    if product[:properties]
      product[:properties].each do |k,v|
      option = { name: k }
      options.push option
      end
    end

    # 設定product的variants
    variants_data = []
    variants = product[:variants]
    variants.each do |v|
      variant = {
        "title": v[:name],
        "barcode": v[:bardcore],
        "sku": v[:sku],
        "inventory_quantity": v[:stock_on_hand],
        "price": "#{v[:retail_price]}".to_f,
        "taxable": v[:taxable],
        "inventory_policy": "continue",
        "inventory_management": "shopify",
        "requires_shipping": true,
        "weight": v[:weight].to_f,
        "weight_unit": "kg",
        "grams": v[:weight].to_f * 1000
      }
      if v[:properties]
        properties_count = v[:properties].length || 0
          properties_count.times do |i|
          values = v[:properties].values
          variant["option#{i + 1}".to_sym] = values[i]
        end
      end
      variants_data.push variant
    end
    # 一次連同variants一起更新data
    product_json = {
      product: {
        "title": product[:name],
        "body_html": product[:description],
        "vendor": product[:default_supplier_name],
        "product_type": product[:product_type_name],
        "published": false,
        "tags": product[:tag_string],
        "options": options,
        "variants": variants_data
      }
    }
  end

  def convert_edited_data(product)
    # 設定product的variants
    variants_data = []
    variants = product[:variants]
    variants.each do |v|
      variant = {
        "id": v[:third_party_id],
        "title": v[:name],
        "barcode": v[:bardcore],
        "sku": v[:sku],
        "inventory_quantity": v[:stock_on_hand],
        "price": "#{v[:retail_price]}".to_f,
        "taxable": v[:taxable],
        "weight": v[:weight].to_f,
        "grams": v[:weight].to_f * 1000
      }
      if v[:properties]
        properties_count = v[:properties].length || 0
          properties_count.times do |i|
          values = v[:properties].values
          variant["option#{i + 1}"] = values[i]
        end
      end
      variants_data.push variant
    end
    # 一次連同variants一起更新data
    product_json = {
      product: {
        "id": product[:third_party_id],
        "title": product[:name],
        "body_html": product[:description],
        "vendor": product[:default_supplier_name],
        "product_type": product[:product_type_name],
        "published": false,
        "tags": product[:tag_string],
        "variants": variants_data
      }
    }
  end

  def send_new_data(data)
    shop = Shop.find_by(shopify_domain: shopify_domain)
    shopify_headers = {"Content-Type"=>"application/json"}
    response = HTTParty.post(
      "https://#{api_key}:#{shop.shopify_token}@#{shopify_domain}/admin/products.json",
      body: data.to_json,
      headers: shopify_headers,
      format: :plain
    )
    JSON.parse(response, symbolize_names: true)
  end

  def send_edited_data(data, options={})
    shop = Shop.find_by(shopify_domain: shopify_domain)
    shopify_headers = {"Content-Type"=>"application/json"}
    response = HTTParty.put(
      "https://#{api_key}:#{shop.shopify_token}@#{shopify_domain}/admin/products/#{options[:path]}",
      body: data.to_json,
      headers: shopify_headers,
      format: :plain
    )
    JSON.parse(response, symbolize_names: true)
  end

  def save_3rd_party_id(product_id, original_data, response)
    variants = []
    original_data[:variants].each do |v|
      third_party_id = response[:product][:variants]
      .select { |x| x[:title].delete(' ') == v[:name] || x[:title] == 'Default Title' }
      .first[:id]
      variant = { id: v[:id], third_party_id: third_party_id } 
      variants.push variant
    end
    data = {
      product: {
        third_party_id: response[:product][:id],
        variants_attributes: variants
      }
    }
    HTTParty.patch("#{venty_url("products/#{product_id}.json")}", body: data, headers: headers)
  end 

  def get_data_from_venty(path)
    response = HTTParty.get(venty_url(path), headers: headers, format: :plain)
    JSON.parse(response, symbolize_names: true)
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