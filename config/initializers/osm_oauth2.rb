require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class OsmOauth2 < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "osm_oauth2"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {:site => "https://www.openstreetmap.org",
          :authorize_url => "https://www.openstreetmap.org/oauth2/authorize", 
          :token_url => "https://www.openstreetmap.org/oauth2/token"}

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.

      extra do
        {
          'raw_info' => raw_info
        }
      end

      uid { raw_info['id'] }

      info do
        raw_info
      end

      def raw_info
        @raw_info ||= parse_info(access_token.get('/api/0.6/user/details').body)
        @raw_info
        rescue ::Errno::ETIMEDOUT
        raise ::Timeout::Error
      end


      private
      def parse_info(xml_data)
        # extract event information
        doc = REXML::Document.new(xml_data)
        user = doc.elements['//user']

        basic_attributes = { }
        basic_attributes['id']           = user.attribute('id').value if user
        basic_attributes['display_name'] = user.attribute('display_name').value if user

        basic_attributes
      end


    end
  end
end