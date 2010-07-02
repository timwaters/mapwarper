class LegacyMap < LegacyBase
  set_table_name "mapscans"

  def migrate_me!
    #    map = Map.create(
    #      :created_at => self.created_at,   # Some fields can be directly ported
    #      :description => self.description || '',   # Some fields may need string processing, but watch out for nils! (self.state || '').downcase is safer
    #      :title => self.title || "map#{self.id}"   # Your app probably validates_presence_of, but don't assume that the old app did!
    #    )
    desc = self.description || ''
    if self.published_date?
      pub = '. Published date: '+ self.published_date
    else
      pub = ''
    end
    
    if self.reprint_date?
      rep = '. Reprint date: '+ self.reprint_date
    else
      rep = ''
    end
    description = desc + pub + rep
    
    unless self.thumbnail? || Map.exists?(self.id)
      print " "+ self.id.to_s
      map = Map.new(
        :created_at => self.created_at || Time.now,
        :updated_at => self.updated_at || Time.now,
        :description => description,   # Some fields may need string processing, but watch out for nils! (self.state || '').downcase is safer
        :title => self.title || "map#{self.id}",   # Your app probably validates_presence_of, but don't assume that the old app did!
        :bbox => self.bbox || '',
        :publisher => self.publisher || '',
        :authors => self.authors || '',
        :scale => self.scale || ''
        # :published_date => self.published_date
        # :reprint_date => self.reprint_date
      )
      map.id = self.id #cannot assign id via create
      
      original_mapscan_image = "/home/tim/work/tc_warper/public/mapimages/"+self.filename
      File.open(original_mapscan_image) { |photo_file| map.upload = photo_file }
      map.save
      
      if map.errors.on(:title)
        map.title = "map#{self.id}"
        map.save
      end
     
    else
      print "."
    end
   
   
    # Compensate for uniqueness issues - it's better to have a generic row than no row at all (your associations think so, at least)
    
  end

  def self.migrate_all
    puts "migrating"
    find(:all).each(&:migrate_me!)
    puts "done"
  end

end



