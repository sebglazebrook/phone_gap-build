# PhoneGap::Build

A simple Ruby api client for PhoneGap Build.

I made this as the only other Ruby gem didn't work.

Selfishly I have/will only include the api calls that I require.

If people start using it or pull requests come in then we'll see what happens.

## Installation

Add this line to your application's Gemfile:

    gem 'phone_gap-build'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install phone_gap-build

## Usage

    require 'phone_gap/build'

    PhoneGap::Build.credentials(token: 'my_api_token')

    apps = PhoneGap::Build.apps

    # update an existing app
    app = apps.first
    app.description = 'Fancy Pants App'
    app.save

    # create a new app
    app = PhoneGap::Build::App.new

    # add any required values (see http://docs.build.phonegap.com/en_US/3.3.0/developer_api_api.md.html#PhoneGap%20Build%20Developer%20API)
    app.title = 'Batman'
    app.create_method = 'file'
    app.file = File.new('./batman-files/gotham.city')

    # save/create the app
    app.save

    # delete it!
    app.destroy

## Contributing

1. Fork it ( https://github.com/sebglazebrook/phone_gap-build/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
