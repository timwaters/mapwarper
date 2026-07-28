require "#{ Rails.root }/lib/misc/gdalinfo.rb"
require "#{ Rails.root }/lib/misc/georuby_extension.rb"

module Hcaptcha

  def self.api_verification(verify_hash, timeout: DEFAULT_TIMEOUT)
    http = if configuration.proxy
      proxy_server = URI.parse(configuration.proxy)
      Net::HTTP::Proxy(proxy_server.host, proxy_server.port, proxy_server.user, proxy_server.password)
    else
      Net::HTTP
    end
    query = URI.encode_www_form(verify_hash)
    uri = URI.parse(configuration.verify_url + '?' + query)
    http_instance = http.new(uri.host, uri.port)
    http_instance.read_timeout = http_instance.open_timeout = timeout
    http_instance.use_ssl = true if uri.port == 443
    http_instance.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)
    JSON.parse(http_instance.request(request).body)
  end

end
