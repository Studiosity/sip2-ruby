[![Travis Build Status](http://img.shields.io/travis/abrom/sip2-ruby.svg?style=flat)](https://travis-ci.org/abrom/sip2-ruby)
[![Code Climate Score](http://img.shields.io/codeclimate/github/abrom/sip2-ruby.svg?style=flat)](https://codeclimate.com/github/abrom/sip2-ruby)
[![Gem Version](http://img.shields.io/gem/v/sip2.svg?style=flat)](#)

# 3M™ Standard Interchange Protocol v2 (SIP2) client implementation in Ruby

This is a gem wrapping the SIP v2 protocol.

http://multimedia.3m.com/mws/media/355361O/sip2-protocol.pdf 


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sip2'
```

And then execute:

```bash
$ bundle
```


## Protocol support

So far only login (code 93) and patron_information (code 63) are supported


## Usage

```ruby
client = Sip2::Client.new(host: 'my.sip2.host.net', port: 6001)
patron =
  client.connect do |connection|
    if connection.login 'sip_username', 'sip_password'
      connection.patron_information 'patron_username', 'patron_password'
    end
  end

puts 'Valid patron' if patron && patron.authenticated?
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/abrom/sip2-ruby.

Note that spec tests are appreciated to minimise regressions. Before submitting a PR, please ensure that:
 
```bash
$ rspec
```
and

```bash
$ rubocop
```
both succeed 


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
