class AnnotationSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper
  attributes :id, :body, :geom, :created_at, :created_ago, :updated_at, :map, :user
  

  def created_at
    object.created_at.strftime("%Y-%m-%d %H:%M")
  end
  
  def created_ago 
    time_ago_in_words(object.created_at)
  end

  def map
      MapSerializer.new(object.map)
  end

  def user
    UserSerializer.new(object.user)
  end

  class UserSerializer < ActiveModel::Serializer
    attributes :login
  end

  class MapSerializer < ActiveModel::Serializer
    attributes :title, :description, :id
  end


end
