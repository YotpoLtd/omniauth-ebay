require 'omniauth'

module OmniAuth
  module Strategies
    class Ebay
      include OmniAuth::Strategy
      include EbayAPI

      args [:runame, :devid, :appid, :certid, :siteid, :apiurl, :loginurl]
      option :name, 'ebay'
      option :loginurl, 'https://signin.ebay.com/ws/eBayISAPI.dll'
      option :runame, nil
      option :devid, nil
      option :appid, nil
      option :certid, nil
      option :siteid, nil
      option :apiurl, nil


      uid { raw_info['EIASToken'] }
      info do
        {
            ebay_id: raw_info['UserID'],
            ebay_token: @auth_token,
            email: raw_info['Email'],
            full_name: raw_info['RegistrationAddress'].try(:[], 'Name'),
            ebay_eias_token: raw_info['EIASToken']
        }
      end

      extra do
        {
            redirect_url: request.env['omniauth.params']['redirect_url'].gsub(" ","+")
        }
      end

      #1: We'll get to the request_phase by accessing /auth/ebay
      #2: Request from eBay a SessionID
      #3: Redirect to eBay Login URL with the RUName and SessionID
      def request_phase
        redirect ebay_login_url(generate_session_id)
      rescue Exception => ex
        fail!('Failed to retrieve session id from ebay', ex)
      end

      #4: We'll get to the callback phase by setting our accept/reject URL in the ebay application settings(/auth/ebay/callback)
      #5: Request an eBay Auth Token with the returned username&secret_id parameters.
      #6: Request the user info from eBay
      def callback_phase
        @auth_token = get_auth_token(request.params['sid'], request.params['username'])
        @user_info = get_user_info(@auth_token)
        super
      rescue Exception => ex
        fail!("Failed to retrieve user info from ebay %s"%ex.message(), ex)
      end

      def raw_info
        @user_info
      end
    end
  end
end

OmniAuth.config.add_camelization 'ebay', 'Ebay'
