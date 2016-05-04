class GcpSerializer < ActiveModel::Serializer
  attributes :id, :map_id, :x, :y, :lat, :lon, :created_at, :updated_at
end


