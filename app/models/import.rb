class Import < ActiveRecord::Base
  require 'csv'
  
  has_many :maps
  belongs_to :layer
  belongs_to :user, :class_name => "User"
  has_and_belongs_to_many :layers

  has_attached_file :metadata,
    path: ":rails_root/db/:class/:attachment/:id_partition/:filename", 
    url:  ":rails_root/db/:class/:attachment/:id_partition/:filename",
    preserve_files: false
  
  validates_attachment_content_type :metadata, content_type: ["text/csv", "text/plain"]
  validates_presence_of :metadata, :message => :no_file_uploaded
  
  acts_as_enum :status, [:ready, :running, :finished, :failed]

  after_initialize :default_values
  after_destroy :delete_logfile
  
  def default_values
    self.status ||= :ready
    self.imported_count ||= 0
  end
  
  def logfile
    "import-#{id}-#{Time.new.strftime('%Y-%m-%d-%H%M%S')}.log"
  end
  
  def log_path
    "#{Rails.root}/log/imports/#{log_filename}"
  end

  def import_logger
    @import_logger ||= Logger.new(log_path)
  end

  
  def prepare_run
    self.update_attribute(:status, :running)
    self.update_attribute(:log_filename, logfile)
  end
  
  def finish_import(options)
    self.status = :finished
    self.finished_at = Time.now
    self.save
    save_maps_to_layers unless self.maps.empty? || self.save_layer == false || self.layer_ids.empty?
    log_info "Finished import #{Time.now}"
  end
  
  def import!(options={})
    options = {:async => false}.merge(options)
    
    async = options[:async]
    if valid? && file_count > 0
      prepare_run unless async
      log_info "Stared import #{Time.now}"
      begin
        import_maps
        finish_import(options)
      rescue => e
        log_error "Error with import #{e.inspect}"
        log_error e.backtrace
        
        self.status = :failed
        self.save
      end
      
    end
    
    self.status
  end
  
  def import_maps
    data = open(self.metadata.path)
    map_data = CSV.parse(data, :headers => true, :header_converters => :symbol, :col_sep => ";")
    map_data.by_row!
    map_data.each do  | map_row |
      uuid = map_row[:uuid]
      if Map.exists?(unique_id: uuid)
        map = Map.find_by_unique_id(uuid)
        map.import_id = self.id
        log_info "Map already exists. Adding it to the import" + map.inspect
        map.save
        next
      end
      photo_uuid = map_row[:fotonummer]
      file_base =  APP_CONFIG['import_maps_sftp_path']+"/"+map_row[:fotonummer]
      next if Dir.glob(file_base+".*").empty?
      upload_filename = Dir.glob(file_base+".*").first
     
      published_date = map_row[:vervaardiging_begindatum]
      issue_year = nil
      unless published_date.blank?
        date = DateTime.parse(published_date)
        issue_year = date.year
      end
      date_depicted = issue_year
    
      description = map_row[:beschrijving]
      unless map_row[:overige_vervaardigersnaamnaam].blank?
        description = description +  " Overige vervaardigers: " + map_row[:overige_vervaardigersnaamnaam]
      end
      unless map_row[:rechthebbendenaam].blank?
        description = description +  " Rechtehbbende: " + map_row[:rechthebbendenaam]
      end
      tags = nil
      tags = map_row[:techniek] unless map_row[:techniek].blank?
      subject_area = nil
      subject_area = map_row[:locatiepreflabel] unless map_row[:locatiepreflabel].blank?
      publisher = nil
      publisher = map_row[:overige_vervaardigersnaamnaam] unless map_row[:overige_vervaardigersnaamnaam].blank?
      authors = nil
      authors = map_row[:primaire_vervaardigernaam] unless map_row[:primaire_vervaardigernaam].blank?
        
      map = {
        title: map_row[:titel],
        description: description,
        published_date: published_date,
        date_depicted: date_depicted,
        issue_year: issue_year,
        source_uri: "https://www.erfgoedleiden.nl/#{uuid}",
        tag_list: tags,
        subject_area: subject_area,
        publisher: publisher,
        authors: authors,
        unique_id: uuid,
        photo_uuid: photo_uuid,
        status: :unloaded,
        map_type: 'is_map',
        public: true
      } 
      map = Map.new(map)
      map.upload = File.new(upload_filename)

      map.import_id = self.id
      map.owner = self.user
      map.users << self.user
      if map.save
        log_info "Saved new Map" + map.inspect
        Import.increment_counter(:imported_count, self.id)
      else
        log_info "Didn't save new Map" + map.inspect
        log_info "Errors" + map.errors.messages.inspect
      end
    end

  end

  def save_maps_to_layers
    log_info "Saving maps to layers"
    ids = self.layer_ids.split(",")
    layers = Layer.find(ids)
    layers.each do | layer |
      log_info "adding maps to layer"
      maps_to_add = self.maps.select{ |map| !layer.maps.include?(map)}
      layer.maps << maps_to_add
      save
    end
    log_info "finished saving maps to layers"
  end

  
  #counts number of files in the directory 
  def dir_file_count
    directory = APP_CONFIG['import_maps_sftp_path']
    Dir[File.join(directory, '**')].count { |file| File.file?(file) }
  end
  
  protected
  

  def log_info(msg)
    puts msg  if defined? Rake
    import_logger.info msg
  end
  
  def log_error(msg)
    puts msg  if defined? Rake
    import_logger.error msg
  end
  
  
  def delete_logfile
    if log_filename && log_filename.include?(".log") && File.exists?("#{Rails.root}/log/imports/#{log_filename}")
      File.delete("#{Rails.root}/log/imports/#{log_filename}")
    end
  end

end
