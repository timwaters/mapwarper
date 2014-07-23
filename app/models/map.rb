require "open3"
class Map < ActiveRecord::Base
  
  has_many :gcps,  :dependent => :destroy
  has_many :layers_maps,  :dependent => :destroy
  has_many :layers, :through => :layers_maps # ,:after_add, :after_remove
  has_many :my_maps, :dependent => :destroy
  has_many :users, :through => :my_maps
  belongs_to :owner, :class_name => "User"
  
  has_attached_file :upload, :styles => {:thumb => ["100x100>", :png]} ,
    :url => '/:attachment/:id/:style/:basename.:extension'
  validates_attachment_size(:upload, :less_than => MAX_ATTACHMENT_SIZE) if defined?(MAX_ATTACHMENT_SIZE)
  #attr_protected :upload_file_name, :upload_content_type, :upload_size
  validates_attachment_content_type :upload, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif", "image/tiff"]

  acts_as_taggable
  acts_as_enum :map_type, [:index, :is_map, :not_map ]
  acts_as_enum :status, [:unloaded, :loading, :available, :warping, :warped, :published]
  acts_as_enum :mask_status, [:unmasked, :masking, :masked]
  acts_as_enum :rough_state, [:step_1, :step_2, :step_3, :step_4]
  acts_as_commentable
  
  attr_accessor :upload_url
  
  after_initialize :default_values
  before_create :download_remote_image, :if => :upload_url_provided?
  before_create :save_dimensions
  after_create :setup_image
  after_destroy :delete_images
  after_destroy :delete_map, :update_counter_cache, :update_layers
  after_save :update_counter_cache
  
  ##################
  # CALLBACKS
  ###################
  
  def default_values
    self.status  ||= :unloaded  
    self.mask_status  ||= :unmasked  
    self.map_type  ||= :is_map  
    self.rough_state ||= :step_1  
  end
  
  def upload_url_provided?
    !self.upload_url.blank?
  end
  
  def download_remote_image
    img_upload = do_download_remote_image
    unless img_upload
      errors.add(:upload_url, "is invalid or inaccessible")
      return false
    end
    self.upload = img_upload
    self.source_uri = upload_url
    
    if Map.find_by_upload_file_name(upload.original_filename)
      errors.add(:filename, "is already being used")
      return false
    end
    
  end
  
  def do_download_remote_image
    begin
      io = open(URI.parse(upload_url))
      def io.original_filename; base_uri.path.split('/').last; end
      io.original_filename.blank? ? nil : io
    rescue => e
      logger.debug "Error with URL upload"
      logger.debug e
      return false
    end
  end
   
  def save_dimensions
    if ["image/jpeg", "image/tiff", "image/png", "image/gif", "image/bmp"].include?(upload.content_type.to_s)      
      tempfile = upload.queued_for_write[:original]
      unless tempfile.nil?
        geometry = Paperclip::Geometry.from_file(tempfile)
        self.width = geometry.width.to_i
        self.height = geometry.height.to_i
      end
    end
    self.status = :available
  end
  
  #this gets the upload, detects what it is, and converts to a tif, if necessary.
  #Although an uploaded tif with existing geo fields may confuse things
  def setup_image
    logger.info "setup_image "
    self.filename = upload.original_filename
    save!
    if self.upload?
      
      if  defined?(MAX_DIMENSION) && (width > MAX_DIMENSION || height > MAX_DIMENSION)
        logger.info "Image is too big, so going to resize "
        if width > height
          dest_width = MAX_DIMENSION
          dest_height = (dest_width.to_f /  width.to_f) * height.to_f
        else
          dest_height = MAX_DIMENSION
          dest_width = (dest_height.to_f /  height.to_f) * width.to_f
        end
        self.width = dest_width
        self.height = dest_height
        save!
        outsize = "-outsize #{dest_width.to_i} #{dest_height.to_i}"
      else
        outsize = ""
      end
      
      orig_ext = File.extname(self.upload_file_name).to_s.downcase
      
      tiffed_filename = (orig_ext == ".tif" || orig_ext == ".tiff")? self.upload_file_name : self.upload_file_name + ".tif"
      tiffed_file_path = File.join(maps_dir , tiffed_filename)
      
      logger.info "We convert to tiff"
      # -co compress=DEFLATE for compression?
      # -expand rgb   for tifs with LZW compression. sigh
      command  = "#{GDAL_PATH}gdal_translate #{self.upload.path} #{outsize} -co PHOTOMETRIC=RGB -co PROFILE=BASELINE #{tiffed_file_path}"
      logger.info command
      ti_stdin, ti_stdout, ti_stderr =  Open3::popen3( command )
      logger.info ti_stdout.readlines.to_s
      logger.info ti_stderr.readlines.to_s
      
      command = "#{GDAL_PATH}gdaladdo -r average #{tiffed_file_path} 2 4 8 16 32 64"
      o_stdin, o_stdout, o_stderr = Open3::popen3(command)
      logger.info command
      
      o_out = o_stdout.readlines.to_s
      o_err = o_stderr.readlines.to_s
      if o_stderr.readlines.empty? && o_err.size > 0
        logger.error "Error gdal overview script" + o_err.inspect
        logger.error "output = "+o_out
      end
      
      self.filename = tiffed_filename
      
      #now delete the original
      logger.debug "Deleting uploaded file, now it's a usable tif"
      if File.exists?(self.upload.path)
        logger.debug "deleted uploaded file"
        File.delete(self.upload.path)
      end
      
    end
    self.map_type = :is_map
    self.rough_state = :step_1
    save!
  end
  
  #paperclip plugin deletes the images when model is destroyed
  def delete_images
    logger.info "Deleting map images"
    if File.exists?(temp_filename)
      logger.info "deleted temp"
      File.delete(temp_filename)
    end
    if File.exists?(warped_filename)
      logger.info "Deleted Map warped"
      File.delete(warped_filename)
    end
    if File.exists?(warped_png)
      logger.info "deleted warped png"
      File.delete(warped_png)
    end
    if File.exists?(unwarped_filename)
      logger.info "deleting unwarped"
      File.delete unwarped_filename
    end
  end
  
  def delete_map
    logger.info "Deleting mapfile"
  end
  
  def update_layer
#    self.layers.each do |layer|
#      layer.update_layer
#    end unless self.layers.empty?
  end
  
  def update_layers
#    logger.info "updating (visible) layers"
#    unless self.layers.visible.empty?
#      self.layers.visible.each  do |layer|
#        layer.update_layer
#      end
#    end
  end
  
  def update_counter_cache
#    logger.info "update_counter_cache"
#    unless self.layers.empty?
#      self.layers.each do |layer|
#        layer.update_counts
#      end
#    end
  end
  
  #############################################
  #CLASS METHODS
  #############################################

  def self.map_type_hash
    values = Map::MAP_TYPE
    keys = ["Index/Overview", "Is a map", "Not a map"]
    Hash[*keys.zip(values).flatten]
  end
  
  def self.max_attachment_size
    max_attachment_size =  defined?(MAX_ATTACHMENT_SIZE)? MAX_ATTACHMENT_SIZE : nil
  end
  
  def self.max_dimension
    max_dimension = defined?(MAX_DIMENSION)? MAX_DIMENSION : nil
  end
  
  #############################################
  #ACCESSOR METHODS
  #############################################

  def maps_dir
    defined?(SRC_MAPS_DIR) ? SRC_MAPS_DIR :  File.join(Rails.root, "/public/mapimages/src/")
  end

  def dest_dir
    defined?(DST_MAPS_DIR) ?  DST_MAPS_DIR : File.join(Rails.root, "/public/mapimages/dst/")
  end


  def warped_dir
    dest_dir
  end

  def unwarped_filename
    File.join(maps_dir, self.filename)
  end

  def warped_filename
    File.join(warped_dir, id.to_s) + ".tif"
  end

  def warped_png_dir
    File.join(dest_dir, "/png/")
  end

  def warped_png
    unless File.exists?(warped_png_filename)
      convert_to_png
    end
    warped_png_filename
  end
  
  def warped_png_filename
    filename = File.join(warped_png_dir, id.to_s) + ".png"
  end

  def warped_png_aux_xml
    warped_png + ".aux.xml"
  end

  def public_warped_tif_url
    "mapimages/dst/"+id.to_s + ".tif"
  end
  
  def public_warped_png_url
    public_warped_tif_url + ".png"
  end

  def mask_file_format
    "gml"
  end

  def temp_filename
    # self.full_filename  + "_temp"
    File.join(warped_dir, id.to_s) + "_temp"
  end

  def masking_file_gml
    File.join(Rails.root, "/public/mapimages/",  self.id.to_s) + ".gml"
  end

  #file made when rasterizing
  def masking_file_gfs
    File.join(Rails.root, "/public/mapimages/",  self.id.to_s) + ".gfs"
  end

  def masked_src_filename
    self.unwarped_filename + "_masked";
  end
  
  
  #############################################
  #INSTANCE METHODS
  #############################################
  
  
  def depicts_year
    self.layers.with_year.collect(&:depicts_year).compact.first
  end
  
  def warped?
    status == :warped
  end
  
  def available?
    return [:available,:warping, :warped, :published].include?(status)
  end

  def published?
    status == :published
  end

  def warped_or_published?
    return [:warped, :published].include?(status)
  end
  
  def last_changed
    if self.gcps.size > 0
      self.gcps.last.created_at
    elsif !self.updated_at.nil?
      self.updated_at
    elsif !self.created_at.nil?
      self.created_at
    else
      Time.now
    end
  end
  
  ############
  #PRIVATE
  ############
  
  def convert_to_png
    logger.info "start convert to png ->  #{warped_png_filename}"
    ext_command = "#{GDAL_PATH}gdal_translate -of png #{warped_filename} #{warped_png_filename}"
    stdin, stdout, stderr = Open3::popen3(ext_command)
    logger.debug ext_command
    if stderr.readlines.to_s.size > 0
      logger.error "ERROR convert png #{warped_filename} -> #{warped_png_filename}"
      logger.error stderr.readlines.to_s
      logger.error stdout.readlines.to_s
    else
      logger.info "end, converted to png -> #{warped_png_filename}"
    end
  end

  
end