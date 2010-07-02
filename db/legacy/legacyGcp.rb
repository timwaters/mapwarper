class LegacyGcp < LegacyBase
  set_table_name "gcps"
def migrate_me!
  unless Gcp.exists?(self.id)
    print "+"
  gcp = Gcp.new(:x => self.x,
                :y => self.y, 
                :lat => self.lat, 
                :lon => self.lon,
              :map_id => self.mapscan_id,
            :created_at => self.created_at || Time.now,
        :updated_at => self.updated_at || Time.now)

     gcp.id = self.id #cannot assign id via create
#      if gcp.errors.on(:x)
#        map.title = "map#{self.id}"
#        map.save
#      end
gcp.save
  else
 print '.'
  end
end

 def self.migrate_all
    puts "migrating"
    find(:all).each(&:migrate_me!)
    puts "done"
  end
end