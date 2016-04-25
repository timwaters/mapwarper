class MapSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :width, :height, :status,:mask_status, :created_at, :updated_at, :bbox, :map_type, :source_uri, :unique_id, :page_id, :date_depicted, :depicts_year, :image_url, :thumb_url
end


