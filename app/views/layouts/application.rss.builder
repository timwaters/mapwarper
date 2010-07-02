xml.instruct! :xml, :version => '1.0'
xml.rss(:version => '2.0') do
  xml << yield
end
