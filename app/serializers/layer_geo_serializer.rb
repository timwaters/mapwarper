class LayerGeoSerializer < ActiveModel::Serializer
  attributes :id, :type, :properties, :geometry

  def type
    "Feature"
  end

  def properties
    { name: object.name, description: object.description, created_at: object.created_at, bbox: object.bbox,
      maps_count: object.maps_count, rectified_maps_count: object.rectified_maps_count, rectified_percent: object.rectified_percent, source_uri: object.source_uri}
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