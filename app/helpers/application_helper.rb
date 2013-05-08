# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  include TagsHelper

Time::DATE_FORMATS[:uk] = "%d-%b-%y %H:%M"
def  button_to_remote(name, options = {}, html_options = {})   
           button_to_function(name, remote_function(options), html_options) 
end 

def snippet(thought, wordcount)
  if thought
   thought.split[0..(wordcount-1)].join(" ") +(thought.split.size > wordcount ? "..." : "")
  end
end

def strip_brackets(str)
  str ||=""
  str.gsub(/[\]\[()]/,"")
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
  html.join(' &gt; '  )
end


def tab_for(tab, link, label=nil)
  
  if @disabled_tabs && @disabled_tabs.include?(tab)
  content_tag :li, "<span class='disabled'>#{label||tab.to_s.titleize}</span>", :class => "disabled_tab" 
  else
  content_tag :li, link_to(label||tab.to_s.titleize, link), :class => ("current_tab" if @current_tab == tab)
  end
  
  end

def periodically_call_remote(options = {})
  variable = options[:variable] ||= 'poller'
  frequency = options[:frequency] ||= 10
  code = "#{variable} = new PeriodicalExecuter(function() 
              {#{remote_function(options)}}, #{frequency})"
  javascript_tag(code)
end


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

def message_for_item(message, item = nil)
  if item.is_a?(Array)
    message % link_to(*item)
  else
    message % item
  end
end

def page_entries_info(collection, options = {})
  entry_name = options[:entry_name] ||
    (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

  if collection.total_pages < 2
    case collection.size
    when 0; "No #{entry_name.pluralize} found"
    when 1; "<b>1</b> #{entry_name}"
    else;   "<b>all #{collection.size}</b> #{entry_name.pluralize}"
    end
  else
    %{<b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b> total} % [
      collection.offset + 1,
      collection.offset + collection.length,
      collection.total_entries
    ]
  end
end

end

