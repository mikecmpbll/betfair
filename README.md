# Betfair

A lightweight ruby wrapper for the Betfair Exchange API (API-NG).

Full API description, including API parameters etc, is available from [Betfair's dedicated API site](https://api.developer.betfair.com/services/webapps/docs/x/G4AS).

Oh, and always [bet responsibly](http://responsiblegambling.betfair.com/). Duh.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'betfair-ng'
```

And then execute:

    $ bundle
    
Or install it yourself as:

    $ gem install betfair-ng

## Usage

```ruby
# create a client with app code
client = Betfair::Client.new("X-Application" => "your_app_code")

# let's log in.
client.interactive_login("your_username", "your_password")

# you can do stuff like list event types:
event_types = client.list_event_types(filter: {})
# =>  [
#       {
#         "eventType"=>{
#           "id"=>"7",
#           "name"=>"Horse Racing"
#         },
#         "marketCount"=>215
#       },
#       ..etc..
#     ]

# todays GB & Ireland horse racing win & place markets
racing_et_id = event_types.find{|et| et["eventType"]["name"] == "Horse Racing"}["eventType"]["id"]

racing_markets = client.list_market_catalogue({
  filter: {
    eventTypeIds: [racing_et_id],
    marketTypeCodes: ["WIN", "PLACE"],
    marketStartTime: {
      from: Time.now.beginning_of_day.iso8601,
      to: Time.now.end_of_day.iso8601
    },
    marketCountries: ["GB", "IRE"]
  },
  maxResults: 200,
  marketProjection: [
    "MARKET_START_TIME",
    "RUNNER_METADATA",
    "RUNNER_DESCRIPTION",
    "EVENT_TYPE",
    "EVENT",
    "COMPETITION"
  ]
})

# given an eventId from the market catalogue (the first for example),
# let's have a flutter shall we?
market = racing_markets.first
market_id = market["marketId"]
selection_id = market["runners"].find { |r| r["runnerName"] == "Imperial Commander" }["selectionId"]

# this places an Betfair SP bet with a price limit of 3.0 .
# see the API docs for the different types of orders.
client.place_orders({
  marketId: market_id,
  instructions: [{
    orderType: "LIMIT_ON_CLOSE",
    selectionId: selection_id,
    side: "BACK",
    limitOnCloseOrder: {
      liability: liability,
      price: 3.0
    }
  }]
})

# log back out.
client.logout
```

## Best practices

### Persistent HTTP connection

Betfair [recommends](https://api.developer.betfair.com/services/webapps/docs/x/VAJL) that we pass the `Connection: keep-alive` header with each request in order to take advantage of HTTP 1.1's ability to have [persistent connections](https://en.wikipedia.org/wiki/HTTP_persistent_connection) which reduces latency for subsequent requests.

This library uses the [`httpi`](https://github.com/savonrb/httpi) gem, which supports a number of different ruby http client adapters. [`httpclient`](https://github.com/nahi/httpclient) and [`net-http-persistent`](https://github.com/drbrain/net-http-persistent) are two which utilise persistent connections by default. To use `net-http-persistent` you should ensure that the gem is installed and in your load path, then set the HTTPI adapter:

```ruby
require 'betfair'
HTTPI.adapter = :net_http_persistent
```

The same goes for `httpclient`, but it's not strictly necessary to explicitly set the adapter as it has a higher [load order precedence](https://github.com/savonrb/httpi/blob/master/lib/httpi/adapter.rb#L16) than the other adapters.

### Account security and authentication

Despite the example in this readme, you should definitely use the [non-interactive](https://api.developer.betfair.com/services/webapps/docs/x/J4Q6) login for your bots; check the Betfair docs about how to set that up. To login this way, use the `non_interactive_login` method:

```ruby
# Performs the login procedure recommended for applications which run autonomously
#   username: Betfair account username string
#   password: Betfair account password string
#   cert_key_file_path: Path to Betfair client certificate private key file
#   cert_key_path: Path to Betfair client certificate public key file associated with Betfair account
client.non_interactive_login(username, password, cert_key_file_path, cert_file_path)
```

This also allows you to use 2-factor authentication for your online account access, which I'd also strongly recommend that you do. I'm pretty sure you wouldn't be comfortable if your bank accounts had nothing more advanced than credential access, and seeing as a lot of you will have a reasonable amount of money stored in your Betfair accounts, I don't think you should settle for that there, either.

## Todo

1. Error handling

## Contributing

1. Fork it ( https://github.com/mikecmpbll/betfair/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
