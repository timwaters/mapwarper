class Layer < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :depicts_year, :maximum => 4,:allow_nil => true, :allow_blank => true
  validates_numericality_of :depicts_year, :if => Proc.new {|c| not c.depicts_year.blank?}
  has_many :layers_maps, :dependent => :destroy
  has_many :maps,:through => :layers_maps
  #has_many :layer_properties #could be has_one
  belongs_to :user
  acts_as_commentable  

  #replace "has_finder" with "named_scope" if we use a newer rails 2 (uses has_finder gem)
  named_scope :visible, :order=> 'id', :conditions => {:is_visible => true}
  named_scope :with_year, :order => :maps_count, :conditions => "depicts_year is not null"
  named_scope :with_maps, :order => :rectified_maps_count, :conditions => "rectified_maps_count >=  1"

  
  after_create :update_layer
  after_destroy :delete_tileindex

  def tileindex_filename;   self.id.to_s + '.shp' ; end
  
  def tileindex_dir
    defined?(TILEINDEX_DIR) ? TILEINDEX_DIR : File.join(RAILS_ROOT, '/db/maptileindex')
  end

  def tileindex_path;  File.join(tileindex_dir, tileindex_filename) ;  end

  def thumb
    if self.maps.first.nil?
      '/images/missing.png'
    elsif !self.maps.first.public?
      '/images/private.png'
    else
      self.maps.first.upload.url(:thumb)
    end
  end

  def update_layer
    create_tileindex
    set_bounds
    #FIXME get_bounds
  end

  def update_counts
    update_attribute(:maps_count, self.maps.real_maps.length)
    update_attribute(:rectified_maps_count, self.maps.warped.count)
  end

  def rectified_maps_count
    self.maps.warped.count #4 = rectified
  end


  def rectified_percent
    percent = ((self.rectified_maps_count.to_f / self.maps_count.to_f) * 100).to_f
    percent.nan? ? 0 : percent
  end

  def publish
    #empty method for publish action of layer
  end

  def merge(destination_layer_id)
    dest_layer = Layer.find(destination_layer_id)
    logger.info "layer #{self.id} merge to #{dest_layer.id.to_s}"

    self.map_layers.each do | map_layer|
      map_layer.layer = dest_layer
      map_layer.save
    end

    self.update_counts
    dest_layer.update_counts
    self.reload #possibly not needed
    dest_layer.reload #possibly not needed
  end

  #removes map from a layer
  def remove_map(map_id)
    logger.info "layer #{self.id} will have map #{map_id} removed from it"
    map_layer = LayersMap.find(:first, :conditions =>["map_id = ? and layer_id = ?", map_id, self.id])
    logger.info "this relationship to be deleted"
    logger.info map_layer.inspect
    map_layer.destroy
   update_counts
   update_layer

  end

  # gdaltindex [-tileindex field_name] [-write_absolute_path] [-skip_different_projection] index_file [gdal_file]*
  def create_tileindex(custom_path=nil)
    logger.info("create tileindex")
    tileindex = custom_path || tileindex_path
    unless self.maps.warped.empty?
      delete_tileindex(tileindex)
      map_list = ""
      #only make a tileindex if the maps are warped. 
      self.maps.warped.each {|map| map_list += (map.warped_filename + " ")}
      command = "gdaltindex -write_absolute_path #{tileindex} #{map_list}"
      logger.info(command)

      stdin, stdout, stderr = Open3::popen3(command)
      out = stdout.readlines.to_s
      err = stderr.readlines.to_s

      if !err.match("ERROR 4: Unable to open #{tileindex}").nil? || err.size <= 0  #error saying "Unable to open spec/fixtures/maps/deleteme.shp" is actually okay!!
        result= true
      else
        logger.error("ERROR with gdaltindex "+ err)
        result= false
      end
    else
      result= false
    end
    
    result
  end



  def get_bounds
    if self.bbox.blank?
      create_tileindex
      set_bounds
    else
      self.bbox
    end
  end

  #sets bbox
  def set_bounds(custom_path=nil)
    logger.debug "set_bounds in layer"
    tileindex = custom_path || tileindex_path
    unless self.maps.warped.empty?
     command = "ogrinfo #{tileindex} -al -so -ro"
      logger.info command
      #stdin, stdout, stderr = Open3::popen3(command)
      stdout, stderr = Open3.capture3( command )
      sout = stdout
      serr = stderr
      if !serr.blank? 
        logger.error "Error set bounds with layer get extent "+ serr
      else
        extent = sout.scan(/^\w+: \(([0-9\-.]+), ([0-9\-.]+)\) \- \(([0-9\-.]+), ([0-9\-.]+)\)$/).flatten.join(",")

        self.bbox = extent.to_s
        extents =  extent.split(",").collect{|f| f.to_f}
         poly_array = [
          [ extents[0], extents[1] ],
          [ extents[2], extents[1] ],
          [ extents[2], extents[3] ],
          [ extents[0], extents[3] ],
          [ extents[0], extents[1] ]
        ]
        logger.error poly_array.inspect
        self.bbox_geom = Polygon.from_coordinates([poly_array], -1)

        @bounds = extent
        save!
      end

    else
      extent = nil
    end
    extent
  end




  ##################
  #PRIVATE
  ##################

  private

  def delete_tileindex(custom_path=nil)
    tileindex = custom_path || tileindex_path
    if File.exists?(tileindex)
      basename = File.basename(tileindex, ".shp")
      basedir = File.dirname(tileindex)
      logger.info "deleting tileindex"
      File.delete(tileindex) #shp
      File.delete( File.join(basedir, (basename+ ".dbf") ) )
      File.delete( File.join(basedir, (basename+".shx") ) )
      File.delete( File.join(basedir, (basename+".qix") ) ) if File.exists?( File.join(basedir, (basename+".qix") ))
      result= true
    else
      result= false
    end

    result
  end


end
