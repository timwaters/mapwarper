module ApplicationHelper
  
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]
  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
    formatted_messages = messages.map do |type|      
      content_tag :div, :id => type.to_s do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    formatted_messages.join
  end
  
  #from rails way
  def breadcrumbs(stop_at_controller=nil)
    return if controller.controller_name == 'home' || controller.controller_name =='my_maps'
    html = [link_to('Home', root_path)]
    #first level
    html << link_to('Search', @link_back) if @link_back
    html << link_to('Maps', maps_path) if @maps || @map
    html << link_to('Map '+@map.id.to_s, map_path(@map)) if @map unless @layer || stop_at_controller
    html << link_to('Map '+@map.id.to_s, map_path(@map)) if @map  && @layers

    #second level
    if @page && @page == "for_map"
      html << link_to('Map Layers', map_layers_path(@map))
    else
      html << link_to('Layers', layers_path) if @layers || @layer
    end

    html << link_to('Layer '+@layer.id.to_s, layer_path(@layer)) if @layer && @layer.id
    html.join(' &gt; '  ).html_safe
  end
  
  
end
