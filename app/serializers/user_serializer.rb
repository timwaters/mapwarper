class UserSerializer < ActiveModel::Serializer
  attributes :login, :created_at, :enabled, :provider
  attribute :email, if: :current_user_is_admin?
  has_many :roles,  if: :current_user_is_admin?
  def current_user_is_admin?
    current_user.has_role?("administrator")
  end
  
  link(:self) { api_v1_user_url(object) }
  
  class RoleSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end