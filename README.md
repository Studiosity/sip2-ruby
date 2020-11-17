[![Travis Build Status](http://img.shields.io/travis/Studiosity/sip2-ruby.svg?style=flat)](https://travis-ci.org/Studiosity/sip2-ruby)
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

### Using TLS

The Sip2::Client will use TLS if a
[SSLContext](https://ruby-doc.org/stdlib-2.4.10/libdoc/openssl/rdoc/OpenSSL/SSL/SSLContext.html)
is passed in the `ssl_context` parameter. There are quite a few ways this can be configured, but that will
depend on how the server being connected to is configured. A basic example is:

```ruby
# Setup a cert store using the system certificates/trust chain
cert_store = OpenSSL::X509::Store.new
cert_store.set_default_paths

# Setup the SSL context
ssl_context = OpenSSL::SSL::SSLContext.new
ssl_context.verify_mode = OpenSSL::SSL::VERIFY_PEER # This is important. We want to verify the certificate is legitimate 
ssl_context.min_version = OpenSSL::SSL::TLS1_2_VERSION # Generally good practice to enforce the most recent TLS version
ssl_context.cert_store = cert_store # Use the certificate store we configured above

# Raise an exception if the certificate doesn't check out
ssl_context.verify_callback = proc do |preverify_ok, context|
  raise OpenSSL::SSL::SSLError, <<~ERROR.strip if preverify_ok != true || context.error != 0
    SSL Verification failed -- Preverify: #{preverify_ok}, Error: #{context.error_string} (#{context.error})
  ERROR

  true
end

client = Sip2::Client.new(host: 'my.sip2.host.net', port: 6001, ssl_context: ssl_context)
```

If you needed to explicitly specify the certificate to be used there are a few options available
to use instead of cert_store (see the documentation for full details and other options):
 * ca_file          - path to a file containing a CA certificate
 * ca_path          - path to a directory containing CA certificates
 * client_ca        - a certificate or array of certificates
 * client_cert_cb   - callback where an array containing an X509 certificate and key are returned

Be sure to validate that your setup behaves the way you expect it to.
Pass in an invalid certificate and see it fails. Pass a mismatching hostname and see it fails. etc.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Studiosity/sip2-ruby.

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
