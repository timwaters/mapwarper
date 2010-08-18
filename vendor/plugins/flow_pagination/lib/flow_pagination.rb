module FlowPagination

  # FlowPagination renderer for (Mislav) WillPaginate Plugin
  class LinkRenderer < WillPaginate::LinkRenderer

     def logger
       RAILS_DEFAULT_LOGGER
     end
    # Render flow navigation
    def to_html
      flow_pagination = ''
      
      if self.current_page < self.last_page
        if  @options[:params] && @options[:params][:controller] 
          cont = @options[:params][:controller]
          @template.params[:controller] = cont
        else
          cont = @template.controller.controller_name
        end
        if  @options[:params] && @options[:params][:action] 
          act = @options[:params][:action]
          @template.params[:action] = act
        else
          act = @template.controller.action_name
        end
        if  @options[:params] && @options[:params][:id] 
          opt_id = @options[:params][:id]
          @template.params[:id] = opt_id
        end


        flow_pagination = @template.button_to_remote(
            'More Results',{
              :url => { :controller => cont,
              :action => act,
              :params => @template.params.merge!(:page => self.next_page)},
              :loading => "$('moar-button').replace('Loading....<br /><img src=\"/images/load.gif\">');",
              :method => "GET"}, {:id => "moar-button",:class=>"moar-button"})
      end
      @template.content_tag(:div, flow_pagination, :id => 'flow_pagination')

    end

    protected

      # Get current page number
      def current_page
        @collection.current_page
      end

      # Get last page number
      def last_page
        @last_page ||= WillPaginate::ViewHelpers.total_pages_for_collection(@collection)
      end

      # Get next page number
      def next_page
        @collection.next_page
      end

  end

end
