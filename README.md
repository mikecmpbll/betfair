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

## Todo

1. Error handling

## Contributing

1. Fork it ( https://github.com/mikecmpbll/betfair/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
