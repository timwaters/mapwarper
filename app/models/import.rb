class Import < ActiveRecord::Base
  has_many :maps
  belongs_to :user, :class_name => "User"
  validates_presence_of :path
  validates_presence_of :name
  validates_presence_of :uploader_user_id

  #
  #      t.column "path", :string
  #      t.column "name", :string
  #      t.column "layer_title", :string
  #      t.column "map_title_suffix", :string
  #      t.column "default_map_description", :string
  #      t.column "default_map_publisher", :string
  #      t.column "map_author", :string
  #      t.column "path", :string
  #      t.column "layer_id", :integer
  #      t.column "uploader_user_id", :integer
  #      t.column "user_id", :integer
  #t.column "imported_count", :integer

  #state = ready, importing, imported

  before_save :count_files
  attr_reader :status_message   #i.e. short message like "Importing..." "Imported 5/10 files..." final status message should trigger log file to show
  attr_reader :activity_log     #log messages to this, given at the end. "filename, imported or not?, any errors, final message"

  def validate_on_create
    errors.add(:path, "does not exist") if !File.exists?(path)
    errors.add(:uploader_user_id, "does not exist") if !User.exists?(uploader_user_id)
  end


  def start_importing
    if self.state == "ready"  #don't want to import maps that are already importing, or that has already been imported
      
    end
    @status_message = "sss"
  end

  protected
  
  def count_files
    self.file_count = 23
  end
 

end
