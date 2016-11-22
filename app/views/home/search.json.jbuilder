json.set! :data do
  json.array! @results do | result |

    item = result.searchable

    title = ""
    href = ""
    thumb = ""
    tiles = ""
    year = ""

    if result.searchable_type == "Map"
      title = item.title
      href  = url_for(map_url(item.id))
      thumb = item.upload.url(:thumb)
      tiles = "#{tile_map_base_url(:id => item.id)}/{z}/{x}/{y}.png"
      year = item.issue_year
    elsif result.searchable_type == "Layer"
      title = item.name
      href  = layer_url(item.id)
      thumb = item.thumb
      tiles = "#{tile_layer_base_url(:id => item.id)}/{z}/{x}/{y}.png"
      year = item.depicts_year
    end

    json.id result.id
    json.type result.searchable_type
    json.title title
    json.description item.description
    json.href href
    json.thumb thumb
    json.tiles tiles
    json.year year
  end
end