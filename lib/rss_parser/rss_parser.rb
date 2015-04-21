# lib/rss_parser.rb

class RssParser
  require 'rexml/document'
  def self.run(url)
    begin
      
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    xml = REXML::Document.new response.body

    data = {
      :title    => xml.root.elements['channel/title'].text,
      :home_url => xml.root.elements['channel/link'].text,
      :rss_url  => url,
      :items    => []
    }
    xml.elements.each '//item' do |item|
      new_items = {} and item.elements.each do |e|
        new_items[e.name.gsub(/^dc:(\w)/,"\1").to_sym] = e.text
      end
      data[:items] << new_items
    end
    data
    rescue SocketError => se
      Rails.logger.error "RssParser SocketError " + se.to_s
      data = {
      :title    => "",
      :home_url => "",
      :rss_url  => url,
      :items    => []
    }
    end

  end

end
