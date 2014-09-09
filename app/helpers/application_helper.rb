module ApplicationHelper
  
  def admin_authorized?
    user_signed_in? && current_user.has_role?('administrator')
  end
  
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]
  def flash_messages
    return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k.to_sym)}
    formatted_messages = messages.map do |type|      
      content_tag :div, :id => type.to_s do
        message_for_item(flash[type], flash["#{type}_item".to_sym])
      end
    end
    formatted_messages.join.html_safe
  end
  
  def message_for_item(message, item = nil)
    if item.is_a?(Array)
     raw message % link_to(*item)
    else
      message % item
    end
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
      html << link_to('Mosaics', layers_path) if @layers || @layer
    end

    html << link_to('Mosaic '+@layer.id.to_s, layer_path(@layer)) if @layer && @layer.id
    html.join(' &gt; '  ).html_safe
  end
  
  def strip_brackets(str)
    str ||=""
    str.gsub(/[\]\[()]/,"")
  end
  
  def snippet(thought, wordcount)
    if thought
      thought.split[0..(wordcount-1)].join(" ") +(thought.split.size > wordcount ? "..." : "")
    end
  end
  
  def error_messages_for(*objects)
    options = objects.extract_options!
    options[:header_message] ||= I18n.t(:"activerecord.errors.header", :default => "Invalid Fields")
    options[:message] ||= I18n.t(:"activerecord.errors.message", :default => "Correct the following errors and try again.")
    messages = objects.compact.map { |o| o.errors.full_messages }.flatten
    unless messages.empty?
      content_tag(:div, :class => "error_messages") do
        list_items = messages.map { |msg| content_tag(:li, msg) }
        content_tag(:h2, options[:header_message]) + content_tag(:p, options[:message]) + content_tag(:ul, list_items.join.html_safe)
      end
    end
  end
  
  def assets(directory)
    assets = {}

    Rails.application.assets.index.each_logical_path("#{directory}/*") do |path|
      assets[path.sub(/^#{directory}\//, "")] = asset_path(path)
    end

    assets
  end
  
end
