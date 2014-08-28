require "digest/sha1"  

module Devise
  module Encryptable
    module Encryptors
      class LegacyRestfulauthentication < Base
        def self.digest(password, stretches, salt, pepper)
          '{SHA}'+ Base64.encode64(Digest::SHA1.digest(password))
        end
      end
    end
  end
end