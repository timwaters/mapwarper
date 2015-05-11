class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
    :recoverable, :rememberable, :trackable, :validatable, :encryptable, 
    :omniauthable, :omniauth_providers => [ :osm, :mediawiki, :github]
  has_many :permissions
  has_many :roles, :through => :permissions
  
  has_many :my_maps, :dependent => :destroy
  has_many :maps, -> { uniq }, :through => :my_maps
 
  has_many :layers, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  
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
      "Wikimedia Commons"
    elsif provider && provider == "osm"
      "OpenStreetMap"
    else
      provider
    end
  end
  
  #Called by Devise 
  #Method checks to see if the user is enabled (it will therefore not allow a user who is disabled to log in)
  def active_for_authentication?
    super and self.enabled?
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
  
  protected

  #called after the user has been destroyed
  #delete all user maps
  def delete_maps
    own_maps.each do | map |
      logger.debug "deleting map #{map.inspect}"
      map.destroy
    end
  end
  
  
end
