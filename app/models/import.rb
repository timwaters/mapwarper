class Import < ActiveRecord::Base
  has_many :maps
  accepts_nested_attributes_for :maps,  :allow_destroy => true
  belongs_to :user, :class_name => "User"
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :uploader_user_id

  before_save :count_files
  before_create :setup_import

  def start_importing
    logger.info "Starting import"
    if state == "ready"  #don't want to import maps that are already importing, or that has already been imported
      self.state = "importing"
      save!
      user = User.find_by_id(uploader_user_id)
      if Layer.exists?(layer_id)
        layer = Layer.find(layer_id)
        logger.info  "Using Layer #{layer.id.to_s}"
      elsif layer_id == -99
        layer = Layer.new(:name => layer_title)
        layer.user = user
        layer.save
        logger.info "Using New Layer #{layer.id.to_s} with title #{layer.name} "
      end

      include_exts = [".tif", ".gif", ".png", ".jpg", ".jpeg", ".tif.png", ".tiff"]
      logger.info "Starting import..."
      count = 0
      Dir.foreach(path) do | ourfilename |
         logger.info "Looking at file: #{ourfilename} "
        unless Map.exists?(:upload_file_name => ourfilename)
          title_suffix = ''
          title_suffix = ' ' + map_title_suffix unless map_title_suffix.blank?
          map = Map.new(:title => ourfilename + title_suffix,
            :description => map_description,
            :publisher => map_publisher,
            :authors => map_author)
          ourfile = File.join(path , ourfilename)

          map.owner = user
          map.users << user
          if layer
            map.layers << layer
          end

          File.open(ourfile) { |photo_file| map.upload = photo_file }
          if map.save
            self.maps << map
            count += 1
            logger.info "Imported! #{count} : #{ ourfilename.to_s}"
          else
            logger.info "Not saved..."
            if map.errors.on(:filename)
              logger.info  "Map has same name, wasn't imported: #{ourfilename.to_s} "
            end
          end

        end if include_exts.include?(File.extname(ourfilename).to_s)

      end

      self.state = "imported"
      self.imported_count = count
      save!
      logger.info "Finished Importing"
    else
      logger.info "Import not ready to be imported"
    end

  end

  def status
    status = ""
    if self.state == "importing"
      status = "Importing: #{self.maps.count} : #{self.file_count}"
    elsif self.state == "imported"
      status = "Finished: #{self.imported_count}"
    else
      status = self.state.to_s
    end
    status
  end

  protected
  
  def validate
    errors.add(:layer_id, "does not exist, or has not been specified properly") unless Layer.exists?(layer_id) || layer_id == nil || layer_id == -99
    errors.add(:uploader_user_id, "does not exist") if !User.exists?(uploader_user_id)
    errors.add(:layer_title, "is blank") if layer_title.blank? && layer_id == -99
    begin
      errors.add(:path, "does not exist") if !File.exists?(path)
      errors.add(:path, "has no files within the directory") if Dir.entries(path).size - 2 == 0
    rescue Errno::ENOENT
    end
  end
  
  def setup_import
    state = "ready"
  end
  
  def count_files
    self.file_count = Dir.entries(self.path).size - 2
  end
 

end
