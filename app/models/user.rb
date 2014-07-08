class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :encryptable
   has_many :permissions
   has_many :roles, :through => :permissions
   
   #attr_accessor :password
   #attr_accessible :password_confirmation
   #attr_accessible :login, :email, :password, :description
end
