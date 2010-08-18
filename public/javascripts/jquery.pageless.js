// =======================================================================
// PageLess - endless page
//
// Author: Jean-Sébastien Ney (jeansebastien.ney@gmail.com)
// Contributors:
//	Alexander Lang (langalex)
// 	Lukas Rieder (Overbryd)
//
// Parameters:
//    currentPage: current page (params[:page])
//    distance: distance to the end of page in px when ajax query is fired
//    loader: selector of the loader div (ajax activity indicator)
//    loaderHtml: html code of the div if loader not used
//    loaderImage: image inside the loader
//    loaderMsg: displayed ajax message
//    pagination: selector of the paginator divs. (if javascript is disabled paginator is required)
//    params: paramaters for the ajax query, you can pass auth_token here
//    totalPages: total number of pages
//    url: URL used to request more data
// Callback Parameters:
//		scrape: A function to modify the incoming data. (Doesn't do anything by default)
//		complete: A function to call when a new page has been loaded (optional)
//		afterStopListener: A function to call when the last page has been loaded (optional)
//
// Requires: jquery + jquery dimensions
//
// Thanks to:
//  * codemonky.com/post/34940898
//  * www.unspace.ca/discover/pageless/
//  * famspam.com/facebox
// =======================================================================
 
(function(jQuery) {
  jQuery.pageless = function(settings) {
    jQuery.isFunction(settings) ? settings.call() : jQuery.pageless.init(settings);
  };
  
  // available params
  // loader: loading div
  // pagination: div selector for the pagination links
  // loaderMsg:
  // loaderImage:
  // loaderHtml:
  jQuery.pageless.settings = {
    currentPage:  1,
    pagination:   '.pagination',
    url:          location.href,
    params:       {}, // params of the query you can pass auth_token here
    distance:     70, // page distance in px to the end when the ajax function is launch
    loaderImage:  "/images/load.gif",
		scrape: function(data) { return data; }  // Don't do anything by default
  };
  
  jQuery.pageless.loaderHtml = function(){
    return jQuery.pageless.settings.loaderHtml || '\
<tr id="pageless-loader" style="display:none;text-align:center;width:100%;">\
<td colspan="4" style="text-align:center;width:100%;"><div class="msg" style="color:#DAC4C6;font-size:2em"></div>\
  <img src="' + jQuery.pageless.settings.loaderImage + '" title="load" alt="loading more results" style="margin: 10px auto" />\
</td></tr>';
  };
 
  // settings params: totalPages
  jQuery.pageless.init = function(settings) {
    if (jQuery.pageless.settings.inited) return;
    jQuery.pageless.settings.inited = true;
    
    if (settings) jQuery.extend(jQuery.pageless.settings, settings);
    
    // for accessibility we can keep pagination links
    // but since we have javascript enabled we remove pagination links 
    if(jQuery.pageless.settings.pagination)
      jQuery(jQuery.pageless.settings.pagination).remove();
    
    // start the listener
    jQuery.pageless.startListener();
  };
  
  // init loader val
  jQuery.pageless.isLoading = false;
  
  jQuery.fn.pageless = function(settings) {
    jQuery.pageless.init(settings);
    jQuery.pageless.el = jQuery(this);
    
    // loader element
    if(settings.loader && jQuery(this).find(settings.loader).length){
      jQuery.pageless.loader = jQuery(this).find(settings.loader);
    } else {
      jQuery.pageless.loader = jQuery(jQuery.pageless.loaderHtml());
      jQuery(this).append(jQuery.pageless.loader);
      // if we use the default loader, set the message
      if(!settings.loaderHtml) { jQuery('#pageless-loader .msg').html(settings.loaderMsg) }
    }
  };
  
  //
  jQuery.pageless.loading = function(bool){
    if(bool === true){
      jQuery.pageless.isLoading = true;
      if(jQuery.pageless.loader)
        jQuery.pageless.loader.fadeIn('normal');
    } else {
      jQuery.pageless.isLoading = false;
      if(jQuery.pageless.loader)
        jQuery.pageless.loader.fadeOut('normal');
    }
  };
  
  jQuery.pageless.stopListener = function() {
    jQuery(window).unbind('.pageless');
  };
  
  jQuery.pageless.startListener = function() {
    jQuery(window).bind('scroll.pageless', jQuery.pageless.scroll);
  };
  
  jQuery.pageless.scroll = function() {
    // listener was stopped or we've run out of pages
    if(jQuery.pageless.settings.totalPages <= jQuery.pageless.settings.currentPage){
      jQuery.pageless.stopListener();
			// if there is a afterStopListener callback we call it
      if (jQuery.pageless.settings.afterStopListener) { jQuery.pageless.settings.afterStopListener.call(); }
      return;
    }
    
    // distance to end of page
    var distance = jQuery(document).height()-jQuery(window).scrollTop()-jQuery(window).height();
    // if slider past our scroll offset, then fire a request for more data
    if(!jQuery.pageless.isLoading && (distance < jQuery.pageless.settings.distance)) {
      jQuery.pageless.loading(true);
      // move to next page
      jQuery.pageless.settings.currentPage++;
      // set up ajax query params
      jQuery.extend(jQuery.pageless.settings.params, {page: jQuery.pageless.settings.currentPage});
      // finally ajax query
      jQuery.get(jQuery.pageless.settings.url, jQuery.pageless.settings.params, function(data){
				var data = jQuery.pageless.settings.scrape(data);
				if (jQuery.pageless.loader) { jQuery.pageless.loader.before(data) } else { jQuery.pageless.el.append(data) }
        jQuery.pageless.loading(false);
        // if there is a complete callback we call it
        if (jQuery.pageless.settings.complete) { jQuery.pageless.settings.complete.call(); }
      });
    }
  };
})(jQuery);
