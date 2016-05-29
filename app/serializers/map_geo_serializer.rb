class MapGeoSerializer < ActiveModel::Serializer
  attributes :id, :type, :properties, :geometry

  def type
    "Feature"
  end

  def properties
    { title: object.title, description: object.description, width: object.width, height: object.height, 
      status: object.status, created_at: object.created_at, bbox: object.bbox, thumb_url: object.thumb_url, 
      page_id: object.page_id }
  end

  def geometry
    if object.bbox_geom
      polygon = GeoRuby::SimpleFeatures::Polygon.from_ewkt(object.bbox_geom.as_text)
      coords = polygon.as_json[:coordinates].to_s
    else
      coords = ""
    end
    {type: "Polygon", coordinates: coords}
  end

end