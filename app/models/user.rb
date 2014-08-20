class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :encryptable, 
    :omniauthable, :omniauth_providers => [:twitter, :osm]
  has_many :permissions
  has_many :roles, :through => :permissions
  
  has_many :my_maps, :dependent => :destroy
  has_many :maps, -> { uniq }, :through => :my_maps
 
  has_many :layers, :dependent => :destroy
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships
  
  validates_presence_of    :login
  validates_length_of      :login,    :within => 3..40
  validates_uniqueness_of  :login, :case_sensitive => false
   
  #attr_accessor :description
  #attr_accessor :password
  #attr_accessible :password_confirmation
  #attr_accessible :login, :email, :password, :description
  
    
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
  
  #Called by Devise 
  #Method checks to see if the user is enabled (it will therefore not allow a user who is disabled to log in)
  def active_for_authentication?
    super and self.enabled?
  end
  
  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    # Create user if not exists
    unless user
      user = User.create(
        login: auth.extra.raw_info.name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.nickname}@twitter.com", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
    end
    user
  end


  def self.find_for_osm_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    # Create user if not exists
    unless user
      user = User.create(
        login: auth.info.display_name,
        provider: auth.provider,
        uid: auth.uid,
        email: "#{auth.info.display_name}@osm.org", # make sure this is unique
        password: Devise.friendly_token[0,20]
      )
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
