Ext.namespace("GeoExt.popup");
/**
 * Class: GeoExt.Popup
 * Popups are a specialized Window that supports anchoring
 *     to a particular feature in a MapPanel.  When a popup
 *     is anchored to a feature, that means that the popup
 *     will visibly point to the feature on the map, and move
 *     accordingly when the map is panned or zoomed.
 *
 * Usage example:
 * (start code)
 *
 * var popup = new GeoExt.Popup({
 *   title: 'My Popup',
 *   feature: feature,
 *   width: 200,
 *   html: "<div>Popup content</div>",
 *   collapsible: true
 * })
 *
 * (end)
 *
 * Inherits from:
 * - {Ext.Window}
 */

/**
 * Constructor: GeoExt.Popup
 * 
 * Parameters:
 * config - {Object} A config object. In addition to the config options
 *     of its parent class, this object can receive specific options,
 *     see the API properties to know about these specific options.
 */
GeoExt.Popup = Ext.extend(Ext.Window, {

    /**
     * APIProperty: anchored
     * {Boolean} True if this popup begins anchored to
     * its feature.  Defaults to true.
     */
    anchored: true,

    /**
     * APIProperty: panIn
     * {Boolean} True if the popup should pan the map so
     * that the popup is fully in view when it is rendered.  Default is true.
     */
    panIn: true,

    /**
     * APIProperty: unpinnable
     * {Boolean} True if the popup should have a
     * "unpin" tool that unanchors it from its feature.
     * Default is true.
     */
    unpinnable: true,

    /**
     * APIProperty: feature
     * {OpenLayers.Feature} An OpenLayers feature that is this
     * popup's anchor. Either this or <lonlat> has to be provided.
     */
    feature: null,

    /**
     * APIProperty: lonlat
     * {OpenLayers.LonLat} An OpenLayers lonlat from which an
     * anchor feature's geometry is made if no feature is provided.
     */
    lonlat: null,

    /*
     * Some Ext.Window defaults need to be overriden here
     * because some Ext.Window behavior is not currently supported.
     */    

    /**
     * Property: animCollapse
     * {Boolean} True to animate the transition when the panel is 
     * collapsed, false to skip the animation.
     * Collapsing animation is not supported yet for popups.
     */
    animCollapse: false,

    /**
     * Property: draggable
     * {Boolean} True to enable dragging of this Panel.
     * Defaults to false because the popup defaults to being
     * anchored, and anchored popups should not be draggable.
     */
    draggable: false,

    /**
     * Property: shadow
     * {Boolean} True to give the popup window a shadow.
     * Defaults to false because shadows are not supported 
     * yet for popups (the shadow does not look good with 
     * the anchor).
     */
    shadow: false,

    /**
     * Property: popupCls
     * {String} CSS class name for the popup DOM elements.
     */
    popupCls: "gx-popup",

    /**
     * Property: ancCls
     * {String} CSS class name for the popup's anchor.
     */
    ancCls: null,

    /**
     * Method: initComponent
     *     Initializes the popup.
     */
    initComponent: function() {        
        if (!this.feature && this.lonlat) {
            this.feature = new OpenLayers.Feature.Vector(new OpenLayers.Geometry.Point(this.lonlat.lon, this.lonlat.lat));
        }

        this.baseCls = this.popupCls + " " + this.baseCls;

        this.elements += ',anc';

        GeoExt.Popup.superclass.initComponent.call(this);
    },

    /**
     * Method: onRender
     *     Executes when the popup is rendered.
     */
    onRender: function(ct, position) {
        GeoExt.Popup.superclass.onRender.call(this, ct, position);
        this.ancCls = this.popupCls + "-anc";

        //create anchor dom element.
        this.createElement("anc", this.el);
    },

    /**
     * Method: initTools
     *     Initializes the tools on the popup.  In particular,
     *     it adds the 'unpin' tool if the popup is unpinnable.
     */
    initTools : function() {
        if(this.unpinnable) {
            this.addTool({
                id: 'unpin',
                handler: this.unanchorPopup.createDelegate(this, [])
            });
        }

        GeoExt.Popup.superclass.initTools.call(this);
    },

    /**
     * APIMethod: addToMapPanel
     *      Adds this popup to a MapPanel.  Assumes that the
     *      MapPanel's map is already initialized and that the
     *      Popup's feature is on the map.
     * 
     * Parameters:
     * mapPanel - {<GeoExt.MapPanel>} a MapPanel to which to
     *     add this popup.
     */
    addToMapPanel: function(mapPanel) {
        this.mapPanel = mapPanel;
        this.map = this.mapPanel.map;

        mapPanel.add(this);
        mapPanel.doLayout();

        this.position();

        /* Anchoring */
        if(this.anchored) {
            this.anchorPopup();
        }

        this.show();

        /* Panning */
        if(this.panIn) {
            this.panIntoView();
        }
    },

    /**
     * Method: setSize
     *     Sets the size of the popup, taking into account
     *     the size of the anchor.
     *     
     * Parameters:
     * w - {Integer}
     * h - {Integer}
     */
    setSize: function(w, h) {
        if(this.anc) {
            var ancSize = this.getAnchorElement().getSize();
            if(typeof w == 'object') {
                h = w.height - ancSize.height;
                w = w.width;
            } else if(!isNaN(h)){
                h = h - ancSize.height;
            }
        }
        GeoExt.Popup.superclass.setSize.call(this, w, h);
    },

    /**
     * Method: position
     *     Positions the popup relative to its feature
     */
    position: function() {
        var centerLonLat = this.feature.geometry.getBounds().getCenterLonLat();
        var centerPx = this.map.getViewPortPxFromLonLat(centerLonLat);

        //This works for positioning with the anchor on the bottom.
        
        //Will have to functionalize this out later and allow
        //for other positions relative to the feature.
        var anchorSelector = "div." + this.ancCls;

        var dx = this.anc.down(anchorSelector).getLeft(true) +
                            this.anc.down(anchorSelector).getWidth() / 2;
        var dy = this.el.getHeight();

        //Assuming for now that the map viewport takes up
        //the entire area of the MapPanel
        this.setPosition(centerPx.x - dx, centerPx.y - dy);
    },

    /**
     * Method: getAnchorElement
     *     Returns the anchor element of the popup
     *
     * Returns:
     * {Ext.Element}
     */
    getAnchorElement: function() {
        var anchorSelector = "div." + this.ancCls;
        var anc = Ext.get(this.el.child(anchorSelector));
        return anc;
    },

    /**
     * Method: anchorPopup
     *     Anchors a popup to its feature
     *     by registering listeners that reposition the popup
     *     when the map is moved.
     */
    anchorPopup: function() {
        this.map.events.on({
            "move" : this.position,
            scope : this            
        });

        this.on({
            "resize": this.position,
            "collapse": this.position,
            "expand": this.position,
            scope: this
        });
    },

    /**
     * APIMethod: unanchorPopup
     *     Unanchors a popup from its feature.
     *     Currently, this removes the popup from its MapPanel
     *     and adds it to the page body.
     */
    unanchorPopup: function() {
        this.unbindFromMapPanel();

        //make the window draggable
        this.draggable = true;
        this.header.addClass("x-window-draggable");
        this.dd = new Ext.Window.DD(this);

        //remove anchor
        this.getAnchorElement().remove();
        this.anc = null;

        //hide unpin tool
        this.tools.unpin.hide();

        //keep track of whether the popup has been collapsed
        var collapsed = this.collapsed;

        //Steps to move this window out to the body
        //TODO: Make 'unpinned' container configurable
        this.mapPanel.remove(this, false);

        this.container = Ext.getBody();
        
        var xy = this.getPosition();
        this.hide();
        this.el.appendTo(Ext.getBody());
        this.setPagePosition(xy[0],xy[1]);
        this.show();

        //recollapse if it was collapsed before
        if(collapsed) {
            this.collapse();
        }
    },

    /** Method: unbindFromMapPanel
     *      Utility method for unbinding events that call for
     *      popup repositioning.
     */
    unbindFromMapPanel: function() {
        //stop position with feature
        this.map.events.un({
            "move" : this.position,
            scope : this
        });

        this.un("resize", this.position);
        this.un("collapse", this.position);
        this.un("expand", this.position);
    },

    /**
     *  APIMethod: panIntoView
     *      Pans the MapPanel's map so that an anchored popup
     *      can come entirely into view, with padding specified
     *      as per normal OpenLayers.Map popup padding.
     */ 
    panIntoView: function() {
        if(!this.anchored) {
            /*
             * If it's not anchored, panning the map won't put popup into view
             */
            return;
        }
        this.position();
        
        var centerLonLat = this.feature.geometry.getBounds().getCenterLonLat(); 
        var centerPx = this.map.getViewPortPxFromLonLat(centerLonLat);

        //assumed viewport takes up whole body element of map panel
        var popupPos =  this.getPosition(true);
       
        var panelSize = [this.mapPanel.getInnerWidth(), this.mapPanel.getInnerHeight()]; // [X,Y]

        var popupSize = this.getSize();

        var newPos = [popupPos[0], popupPos[1]];

        //For now, using native OpenLayers popup padding.  This may not be ideal.
        var padding = this.map.paddingForPopups;

        // X
        if(popupPos[0] < padding.left) {
            newPos[0] = padding.left;
        } else if(popupPos[0] + popupSize.width > panelSize[0] - padding.right) {
            newPos[0] = panelSize[0] - padding.right - popupSize.width;
        }

        // Y
        if(popupPos[1] < padding.top) {
            newPos[1] = padding.top;
        } else if(popupPos[1] + popupSize.height > panelSize[1] - padding.bottom) {
            newPos[1] = panelSize[1] - padding.bottom - popupSize.height;
        }

        var dx = popupPos[0] - newPos[0];
        var dy = popupPos[1] - newPos[1];

        this.map.pan(dx, dy);
    },

    /**
     * Method: beforeDestroy
     *     Cleanup events before destroying the popup.
     */
    beforeDestroy: function() {
        this.unbindFromMapPanel();
        GeoExt.Popup.superclass.beforeDestroy.call(this);
    }
});

Ext.reg('gx_popup', GeoExt.Popup); 
