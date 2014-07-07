class User < ActiveRecord::Base
   has_many :permissions
   has_many :roles, :through => :permissions
   
   attr_accessor :password
   attr_accessible :password_confirmation
   attr_accessible :login, :email, :password, :description
end
