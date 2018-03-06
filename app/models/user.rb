class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable 
  # :encryptable  for custom authentication methods
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable,
    :omniauthable, :omniauth_providers => [ :osm, :facebook, :github]

  acts_as_token_authenticatable

  has_many :permissions
  has_many :roles, :through => :permissions
  
  has_many :my_maps, :dependent => :destroy
  has_many :maps, -> { uniq }, :through => :my_maps
 
  has_many :layers, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  has_many :user_warnings
  
  validates_presence_of    :login
  validates_length_of      :login,    :within => 3..40
  validates_uniqueness_of  :login, :scope => :email, :case_sensitive => false
  
    
  after_destroy :delete_maps
   
  def has_role?(name)
    self.roles.find_by_name(name) ? true : false
  end
  
  def own_maps
    Map.where(["owner_id = ?", self.id])
  end

  def own_this_map?(map_id)
    Map.exists?(:id => map_id.to_i, :owner_id => self.id)
  end

  def own_this_layer?(layer_id)
    Layer.exists?(:id => layer_id.to_i, :user_id => self.id)
  end
  
  #override the confirm method from devise, called when a user confirms their email. Email auth only
  def confirm!
    UserMailer.new_registration(self).deliver_now
    super
  end
  

  def force_confirm!
    self.update_attribute(:confirmed_at, Time.now.utc)
  end
  
  
  def provider_name
    if provider && provider == "mediawiki"
      I18n.t('devise.shared.links.wikimedia')
    elsif provider && provider == "osm"
      I18n.t('devise.shared.links.openstreetmap')
    else
      provider
    end
  end
  
  #Called by Devise 
  #Method checks to see if the user is enabled (it will therefore not allow a user who is disabled to log in)
  def active_for_authentication?
    super && self.enabled? && self.is_allowed_in?
  end

  def inactive_message
    self.is_allowed_in? ? super : :not_allowed_in
  end
  
  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    # Create user if not exists
    unless user
      user = User.new(
        login: auth.extra.raw_info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.nickname}@twitter.com", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end
    user
  end


  def self.find_for_osm_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    # Create user if not exists
    unless user
      user = User.new(
        login: auth.info.display_name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.display_name}+warper@osm.org", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end
    user
  end
  
  def self.find_for_mediawiki_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid.to_s).first
    # Create user if not exists
    unless user
      user = User.new(
        login: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.name}+warper@mediawiki.org", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end
    user
  end
  
  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid.to_s).first
 
    unless user
      user = User.new(
        login: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.nickname}+warper@github.com", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end
    user
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid.to_s).first
    logger.debug auth.info.inspect 
    unless user
      user = User.new(
        login: auth.info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: "warper_fb_"+auth.info["email"], # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
      user.skip_confirmation!
      user.save!
    end
    
    user
  end
  
  alias :devise_valid_password? :valid_password?

  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      return false unless Devise::Encryptable::Encryptors::LegacyRestfulauthentication.digest(password, nil,nil,nil) == encrypted_password
      logger.info "User #{email} is using the old password hashing method, updating password to bcrypt."
      self.password = password
      true
    end
  end

  def update_own_maps_count
    update_column(:own_maps_count, own_maps.count)
  end

  #upload_file_size is in bytes
  def update_upload_filesize_sum
    update_column(:upload_filesize_sum, own_maps.sum(:upload_file_size)) 
  end
 
  def update_map_counts
    update_own_maps_count
    update_upload_filesize_sum
  end

  def update_disk_usage
    update_column(:disk_usage, calculate_disk_usage)
  end

  #returns tiffed disk usage in units of 1024 bytes
  def calculate_disk_usage
    user_own_maps = self.own_maps  #saves 4 calls

    files = user_own_maps.map{|m| m.unwarped_filename if File.exist? m.unwarped_filename} + user_own_maps.map{| m | m.masked_src_filename if File.exist? m.masked_src_filename} + user_own_maps.map{|m | m.warped_filename if File.exist? m.warped_filename} + user_own_maps.map{|m| m.warped_png_filename if File.exist? m.warped_png_filename}
    files.compact!
    files_string = files.join("' '")

    command = "du -c '#{files_string}'"
  
    logger.debug "Calculate disk usage size for user:#{self.id}  #{command}"

    total_size = `#{command}`.split("\n").last.split("\t").first

    return total_size
  end

  protected

  def is_allowed_in?
    APP_CONFIG["disabled_site"] != true || has_role?("administrator")
  end

  #called after the user has been destroyed
  #delete all user maps
  def delete_maps
    own_maps.each do | map |
      logger.debug "deleting map #{map.inspect}"
      map.destroy
    end
  end
  
  
end
