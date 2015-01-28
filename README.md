# Betfair

A library for the Betfair Exchange API. Not yet usable, still in early development stage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'betfair', github: 'mikecmpbll/betfair'
```

And then execute:

    $ bundle

## Usage

```ruby
# create a client with app code (should the app code just be part of the login? no clue what app codes are for tbh.)
client = Betfair::Client.new("your_app_code")

# let's log in.
client.interactive_login("your_username", "your_password")

# and then log back out.
client.logout
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/betfair/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
