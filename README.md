# Betfair

A library for the Betfair Exchange API (API-NG). Still in early development stage.

Full API description, including API parameters etc, is available from [Betfair's dedicated API site](https://api.developer.betfair.com/services/webapps/docs/display/1smk3cen4v3lu3yomq5qye0ni/API-NG+Overview).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'betfair', github: 'mikecmpbll/betfair'
```

And then execute:

    $ bundle

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

# list todays GB & Ireland horse racing events: (note: an event in
# horse racing is a meeting)
racing_et_id = event_types.find{|et| et["eventType"]["name"] == "Horse Racing"}["eventType"]["id"]

events = client.list_events({
  filter: {
    eventTypeIds: [racing_et_id],
    marketStartTime: {
      from: Time.now.beginning_of_day.iso8601,
      to: Time.now.end_of_day.iso8601
    },
    marketCountries: ["GB", "IRE"]
  }
})
# =>  [
#       {
#         "event"=>{
#           "id"=>"27358916",
#           "name"=>"Ling 2nd Feb",
#           "countryCode"=>"GB",
#           "timezone"=>"Europe/London",
#           "venue"=>"Lingfield",
#           "openDate"=>"2015-02-02T13:45:00.000Z"
#         },
#         "marketCount"=>12
#       },
#       .. etc ..
#     ]

# log back out.
client.logout
```

## Contributing

1. Fork it ( https://github.com/mikecmpbll/betfair/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
