require 'RubyBtce/version'
require 'RubyBtce/configuration'
require 'json'
require 'open-uri'
require 'httparty'
require 'hashie'

module RubyBtce
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.load_api_config
    return if @configuration.valid?

    @configuration.load_from_file

    fail ConfigurationException.new unless @configuration.valid?
  end

  def self.round_off(value, places)
    (value.to_f * (10**places)).floor / (10.0**places)
  end

  def self.cleanup_trade_params(opts)
    opts.symbolize_keys!
    price = opts[:rate]
    pair_precision = @configuration.pair_precision(opts[:pair])
    opts[:rate] = round_off(price, pair_precision)

    amount = opts[:amount]
    opts[:amount] = round_off(amount, 8)

    opts
  end

  def self.http_request(payload)
    signature = OpenSSL::HMAC.hexdigest('sha512', @configuration.secret, payload)

    Net::HTTP.start('btc-e.com', 443, use_ssl: true) do |http|
      headers = { 'Sign' => signature, 'Key' => @configuration.key }
      response = http.post('/tapi', payload, headers).body
      return JSON.parse(response)
    end
  end

  def self.api(method, opts)
    load_api_config
    params = { 'method' => method, 'nonce' => nonce }

    unless opts.empty?
      opts = cleanup_trade_params(opts) if method == 'Trade'
      params = params.merge(opts)
    end

    payload = params.collect do |key, val|
      "#{key}=#{CGI.escape(val.to_s)}"
    end.join('&')

    http_request(payload)
  end

  def self.nonce
    while result = Time.now.to_i and @nonce and @nonce >= result
      sleep 1
    end
    return @nonce = result
  end

  def self.parse_response(response)
    return response['error'] unless response['success'] == 1

    Hashie::Mash.new(response['return']) if response['success'] == 1
  end

  def self.all_currencies
    @pairs.map(&:to_s).join('-')
  end

  def self.account
    response = RubyBtce.api('getInfo', {})
    parse_response(response)
  end

  def self.new_trade(opts = {})
    response = RubyBtce.api('Trade', opts)
    parse_response(response)
  end

  def self.cancel(opts = {})
    response = RubyBtce.api('CancelOrder', opts)
    parse_response(response)
  end

  def self.orders(opts = {})
    response = RubyBtce.api('ActiveOrders', opts)
    parse_response(response)
  end

  def self.transactions(opts = {})
    response = RubyBtce.api('TransHistory', opts)
    parse_response(response)
  end

  def self.trades(opts = {})
    response = RubyBtce.api('TradeHistory', opts)
    parse_response(response)
  end

  def self.ticker
    response = JSON.parse(open("https://btc-e.com/api/3/ticker/#{all_currencies}").read)
    parse_response(response)
  end

  def self.pair_info
    request = JSON.parse(open('https://btc-e.com/api/3/info').read)
    Hashie::Mash.new(request['pairs'])
  end

  def self.depth(limit)
    request = JSON.parse(open("https://btc-e.com/api/3/depth/#{all_currencies}?limit=#{limit}").read)
    Hashie::Mash.new(request)
  end

  def self.order_book(limit)
    request = JSON.parse(open("https://btc-e.com/api/3/trades/#{all_currencies}?limit=#{limit}").read)
    Hashie::Mash.new(request)
  end
end
