class LegacyBase < ActiveRecord::Base
  establish_connection(
    :adapter => "mysql",
      :socket =>"/var/run/mysqld/mysqld.sock",
      :username => "root",
      :database => "geowarp_development"
    )
self.abstract_class = true

end
