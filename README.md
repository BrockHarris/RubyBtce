# RubyBtce

RubyBtce provides a simple and clean API wrapper for interfacing with the BTC-e API in a Rails app or CLI.

## Installation

Add this line to your application's Gemfile:

    gem 'RubyBtce'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install RubyBtce

Add the following file to `/config`, and name it `btce_api.yml`:

    # /{Rails.root}/config/btce_api.yml

    key: 'your_api_key'
    secret: 'your_api_secret'

Or add the following file to `/initializers`, and name it `btce_api.rb`:

    # /{Rails.root}/initializers/btce_api.rb

    RubyBtce.configure do |config|
      config.key = ENV['BTCE_API_KEY']
      config.secret = ENV['BTCE_API_SECRET']
    end

## Usage

This gem provides class methods for all public/private API methods offered by BTC-e.
All responses will be returned in a ruby hash format, closely following the structure shown in the BTC-e API [documentation](https://btc-e.com/api/documentation).

### Public Methods

#### Ticker `ticker`
    RubyBtce.ticker.btc_usd.last
    => 555.127

#### Pair Info `pair_info`
    RubyBtce.pair_info.btc_usd.fee
    => 0.2

#### Depth `depth(limit)`
    RubyBtce.depth(2).btc_usd.asks
    => [[554.32, 0.25], [554.329, 0.034]]

#### Order Book `order_book(limit)`
    RubyBtce.order_book(2).btc_usd.first.price
    => 553

### Private Methods

#### Account Info `account`
    RubyBtce.account.funds.btc
    => 0.02199302

#### New Trade `new_trade(opts={})`
This method will take up the values for `rate` and `amount` in the format of a string, integer, or float. You can pass these parameters with any number of decimal places, which will automatically be cut off (not rounded) to the maximum number of places for the specific currency.

    @trade = RubyBtce.new_trade("pair" => "btc_usd", "type" => "sell", "rate"=>"600", "amount"=>"0.02")

    @trade.funds.btc
    => 0.00199302

    @trade.order_id
    => 242304103

#### Cancel Trade `cancel(opts={})`
    @trade = RubyBtce.cancel("order_id"=>242304103)

    @trade.funds.usd
    => 50.35772684

    @trade.order_id
    => 242304103

#### Active Orders `orders(opts={})`
    @orders = RubyBtce.orders("pair" => "btc_usd")

    @orders.each do |id, order|
      id
      => 242304103

      order.status
      => 0
    end

#### Trade History `trades(opts={})`
    @trades = RubyBtce.trades("pair" => "btc_usd")

    @trades.each do |id, trade|
      id
      => 35308202

      trade.order_id
      => 242304103
    end

#### Transaction History `transactions(opts={})`
    @transactions = RubyBtce.transactions("from_id" => "242304103", "end_id" => "242304103", "order" => "ASC")

    @transactions.each do |id, transaction|
      id
      => 56116202

      transaction.desc
      => Bought 0.02 BTC from your order :order:242304103: by price 600 USD total 12 USD (-0.2%)
    end

## Contributing

1. Fork it ( http://github.com/<my-github-username>/RubyBtce/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
