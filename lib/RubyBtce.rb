require "RubyBtce/version"
require 'json'
require 'open-uri'
require 'httparty'
require 'hashie'


module RubyBtce
	def self.return_error
    puts "BTC-e error: you may have sent invalid parameters/credentials, or made requests to frequently."
    return false
	end

  def self.round_off(value, places)
    result = (value.to_f * (10 ** places)).floor / (10.0 ** places)
    return result
  end

  def self.cleanup_trade_params(opts)
    price = opts["rate"]
    amount = opts["amount"]

    pairs = {  
      "btc_usd" => 3,
      "btc_eur" => 3,
      "btc_rur" => 4,
      "eur_usd" => 4,
      "eur_rur" => 4,
      "ftc_btc" => 4,
      "nvc_btc" => 4,
      "nvc_usd" => 4,
      "ppc_btc" => 4,
      "usd_rur" => 4,
      "ppc_usd" => 4,
      "ltc_rur" => 4,
      "nmc_btc" => 4,
      "ltc_btc" => 5,
      "ltc_eur" => 6,
      "ltc_usd" => 6,
      "nmc_usd" => 6,
      "trc_btc" => 6,
      "xpm_btc" => 6
    }

    pairs.each do |key, val|
      if opts["pair"] == key
        opts["rate"] = round_off(price, val)
        opts["amount"] = round_off(amount, 8)
      end
    end
    return opts
  end

  def self.api(method, opts)
    path = File.join(File.dirname(__FILE__), '..', 'config', 'btce_api.yml')
    if File.exists?(path)
      config = YAML.load_file(path)
    else
      config = YAML.load_file(File.join(Rails.root, "config", "btce_api.yml"))
    end

    key = config['key']
    secret = config['secret']

    params = {"method" => method, "nonce" => nonce}
    
    unless opts.empty?
      if method == "Trade"
        opts = cleanup_trade_params(opts)
      end
    	opts.each do |key, val|
        params[key.to_s] = val
      end
    end
    
    payload = params.collect do |key, val|
      "#{key}=#{CGI::escape(val.to_s)}"
    end.join('&')

    signature = OpenSSL::HMAC.hexdigest('sha512', secret, payload)
   
    Net::HTTP.start('btc-e.com', 443, :use_ssl => true) do |http|
      headers = {'Sign' => signature, 'Key' => key}
      response = http.post('/tapi', payload, headers).body
      return JSON.parse(response)
    end
  end

  def self.nonce
    while result = Time.now.to_i and @nonce and @nonce >= result
      sleep 1
    end
    return @nonce = result
  end

  def self.all_currencies
  	currencies = 'btc_usd-btc_rur-btc_eur-btc_cnh-btc_gbp-ltc_btc-ltc_usd-ltc_rur-ltc_eur-ltc_cnh-ltc_gbp-nmc_btc-nmc_usd-nvc_btc-nvc_usd-usd_rur-eur_usd-eur_rur-usd_cnh-gbp_usd-trc_btc-ppc_btc-ppc_usd-ftc_btc-xpm_btc'
  end

	def self.account
  	request = RubyBtce.api("getInfo", opts={})
   	if request['success'] == 1
    	return response = Hashie::Mash.new(request['return'])
    else
    	return request['error']
    end
  end

  def self.new_trade(opts={})
    request = RubyBtce.api("Trade", opts)
    if request['success'] == 1
      return response = Hashie::Mash.new(request['return'])
    else
      return request['error']
    end
  end

  def self.cancel(opts={})
    request = RubyBtce.api("CancelOrder", opts)
    if request['success'] == 1
      return response = Hashie::Mash.new(request['return'])
    else
      return request['error']
    end
  end

  def self.orders(opts={})
    request = RubyBtce.api("ActiveOrders", opts)
    if request['success'] == 1
      return response = Hashie::Mash.new(request['return'])
    else
      return request['error']
    end
  end

  def self.transactions(opts={})
  	request = RubyBtce.api("TransHistory", opts)
   	if request['success'] == 1
    	return response = Hashie::Mash.new(request['return'])
    else
    	return request['error']
    end
  end

  def self.trades(opts={})
    request = RubyBtce.api("TradeHistory", opts)
    if request['success'] == 1
      return response = Hashie::Mash.new(request['return'])
    else
      return request['error']
    end
  end

  def self.ticker
  	request = JSON.parse(open("https://btc-e.com/api/3/ticker/#{self.all_currencies}").read)
  	if request['success'] == 0
    	self.return_error
    else
    	return response = Hashie::Mash.new(request)
    end
  end

  def self.pair_info
  	request = JSON.parse(open("https://btc-e.com/api/3/info").read)
  	return response = Hashie::Mash.new(request['pairs'])
  end

  def self.depth(limit)
  	request = JSON.parse(open("https://btc-e.com/api/3/depth/#{self.all_currencies}?limit=#{limit}").read)
  	return response = Hashie::Mash.new(request)
  end

  def self.order_book(limit)
  	request = JSON.parse(open("https://btc-e.com/api/3/trades/#{self.all_currencies}?limit=#{limit}").read)
  	return response = Hashie::Mash.new(request)
  end
end
#require 'RubyBtce/operations/balances'
