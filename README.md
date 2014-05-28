# AppleLoad

A CLI & Ruby Library to control Apple's Application Loader app.

This is *experimental* - good enough for deploying apps made with [Propeller](http://usepropeller.com), but has not been exhaustively tested beyond our needs.

## Installation

Add this line to your application's Gemfile:

    gem 'appleload'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install appleload

## Usage

AppleLoad generates AppleScript commands, which means that Application Loader will require window focus - in other words, you can't do anything else with your keyboard or mouse while it runs.

### Commands

The following commands are supported:

- `list` - List all the apps which are waiting for an upload
- `upload TITLE IPA_PATH` - Upload the .ipa at IPA_PATH for app named TITLE

### CLI

```bash
$ appleload list
{"apps":[{"title":"My Awesome App","version":"1.0.0","type":"ios"}]}

$ appleload upload "My Awesome App" ./app.ipa
```

### Ruby

```ruby
require 'appleload'

AppleLoad.list
# => [{title: "My Awesome App", version: "1.0.0", type: :is}]

AppleLoad.upload("My Awesome App", "./app.ipa")
# => true
```

## Contact

[Clay Allsopp](http://clayallsopp.com/)
- [clay@usepropeller.com](mailto:clay@usepropeller.com)
- [@clayallsopp](https://twitter.com/clayallsopp)

## License

AppleLoad is available under the MIT license. See the [LICENSE](LICENSE) file for more info.