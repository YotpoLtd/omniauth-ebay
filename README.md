# OmniAuth eBay

![OmniAuth-Ebay!](http://dl.dropbox.com/u/7525692/omniauthebay.png)

In this gem you will find an OmniAuth eBay strategy that is compliant with the Open eBay Apps API.
You can read all about it here: [Open eBay Apps Developers Zone](http://developer.ebay.com/DevZone/open-ebay-apps/Concepts/OpeneBayUGDev.html)

## Usage

Note: The examples are for a Rails 3 app.

* Add our gem to your Gemfile:

`gem 'omniauth-ebay'`

* Add to your omniauth initializer (`config/initializers/omniauth.rb`) the ebay strategy like so:

```ruby
    Rails.application.config.middleware.use OmniAuth::Builder do
       provider :ebay, "runame", "devid", "appid", "certid", "siteid", "apiurl", "loginurl"
    end
```

Where ruName you can get from your dev zone in applications tab under manage you applications concent form there is a section called manage your RuNames.
devid, appid, certid are from the application tab.
siteid can be 0 for US and other numbers for other ebay sites checout their documentation for full list.
apiurl for production is https://api.ebay.com/ws/api.dll for the us site and for the sendbox is https://api.sendbox.ebay.com/ws/api.dll
loginurl for production is https://signin.ebay.com/ws/eBayISAPI.dll for the us site (I don't know if it changes for other sites) and for the sendbox https://signin.sendbox.ebay.com/ws/eBayISAPI.dll

Insert your app credentials in the given order. You can find out these details by going into your developer's account at [eBay DevZone](https://developer.ebay.com/DevZone/account/)

* To use the strategy, you will need to access it's omniauth provider path: `/auth/ebay`. The callback phase path is the default one: `/auth/ebay/callback`.
You will need to define the callback path in your relevant app RUname, so don't forget to set the accept/reject paths in the devzone to the callback path.

* Set a route to the callback path of your sessions controller, and handle the session creation there. You will be able to access
the omniauth session data by accessing `request.env['omniauth.auth']`

## Requirements

Ruby 1.8.7+, Rails 3.0+, OmniAuth 1.0+.

# How it Works

The ebay strategy module uses the standard omniauth strategy module, and it also uses a small module
designed just for the eBay API calls.

## Request Phase

* API call to eBay, requesting a session id.
* Redirecting to eBay login with the session id.

## Callback Phase

* API call to eBay, requesting an ebay auth token, with the secret id and username retrieved from the request.
* API call to eBay, requesting the user's info by using the ebay auth token from the last call.
* The strategy's UID is the eBay EIAS Token. Also these fields will also be exposed by accessing `request.env['omniauth.auth'].info`:

`ebay_id` - The user's eBay username.

`ebay_token` - The current session's auth token, to be used for API calls.

`email` - The user's email address.

* Extra data - We're also passing an optional parameter, `return_to`, which allows you to specify a URL you want the redirect the user to when the authentication process is completed.

