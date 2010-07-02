/*
 * Copyright (C) 2007-2008  Camptocamp
 *
 * This file is part of MapFish Client
 *
 * MapFish Client is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MapFish Client is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MapFish Client.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * This class can be used to draw a routing path on a map.
 * A routing object is constructed by giving it a map and an URL to the routing
 * service.
 * An itinerary will be requested and drawn when calling the fetchRoute() method
 * Routing parameters are opaque to this class, they have to be provided by the
 * consumer and handled on the server side.
 * Server response must be a GeoJSON object which will be drawn on a layer.
 * In case of error, the response must start with the string "error" and may
 * contain an additional message afterwards.
 * Point features can be returned with attributes _isSourceNode or _isTargetNode
 * to be drawn with a source or target icon respectively.
 *
 * @requires OpenLayers/Layer/Vector.js
 * @requires OpenLayers/Format/GeoJSON.js
 */
mapfish.Routing = OpenLayers.Class({

    /**
     * {String} URL for routing service
     */
    url: null,

    /**
     * {<OpenLayers.Layer.Vector>} Layer for rendering features.
     */
    vector: null,

    /**
     * {<OpenLayers.Format.GeoJSON>} GeoJSON parser
     */
    parser: null,

    /**
     * Create a new MapFish.Routing
     *
     * Parameters:
     * url - {String} URL for routing service.
     * map - {<OpenLayers.Map>} The map where to add the routing layer
     * options - {Object} An optional object whose properties will be used
     *     to extend the plugin.
     */
    initialize: function(url, map, options) {
        this.url = url;
        this.map = map;

        OpenLayers.Util.extend(this, options);

        this.parser = new OpenLayers.Format.GeoJSON();

        this.vector = new OpenLayers.Layer.Vector("Routing");
        this.map.addLayer(this.vector);
    },

    onSuccess: function(result) {
        if (result.responseText.search(/^error/) != -1) {
            OpenLayers.Console.error("Routing data returned by server contains error: " +
                                     result.responseText);
            this.onFailure(result);
            return;
        }

        this.vector.destroyFeatures();

        var features = this.parser.read(result.responseText);
        if (!features) {
            this.onFailure("can't parse features");
            return;
        }

        var bounds = features[0].geometry.getBounds();

        for (var i = 0; i < features.length; i++) {
            if (features[i].attributes._isSourceNode) {
                features[i].style = mapfish.Routing.firstPointStyle;
            } else if (features[i].attributes._isTargetNode) {
                features[i].style = mapfish.Routing.lastPointStyle;
            } else {
                bounds.extend(features[i].geometry.getBounds());
                features[i].style = mapfish.Routing.routeStyle;
            }
        }
        this.vector.addFeatures(features);

        if (!this.map.getExtent().containsBounds(bounds)) {
            this.map.zoomToExtent(bounds);
        }
    },

    onFailure: function(result) {
        OpenLayers.Console.error("Failed to fetch routing data: " + result);
    },

    fetchRoute: function(params) {
        new OpenLayers.Ajax.Request(this.url,
                {method: "get",
                 parameters: params,
                 onSuccess: OpenLayers.Function.bind(this.onSuccess, this),
                 onFailure: OpenLayers.Function.bind(this.onFailure, this)});
    }
});


// default style for route
mapfish.Routing.routeStyle = {
    strokeColor: "blue",
    strokeWidth: 6,
    strokeOpacity: 0.4
};

OpenLayers.Util.applyDefaults(mapfish.Routing.routeStyle,
                              OpenLayers.Feature.Vector.style['default']);

mapfish.Routing.firstPointStyle = {
    externalGraphic: mapfish._getScriptLocation() +
                     "img/routing-start-node.png",
    graphicWidth: 18,
    graphicHeight: 26,
    graphicYOffset: -26,
    fillOpacity: 1,
    cursor: 'pointer'
};
OpenLayers.Util.applyDefaults(mapfish.Routing.firstPointStyle,
                              OpenLayers.Feature.Vector.style['default']);


mapfish.Routing.lastPointStyle = {
    externalGraphic: mapfish._getScriptLocation() +
                     "img/routing-stop-node.png",
    graphicWidth: 18,
    graphicHeight: 26,
    graphicYOffset: -26,
    fillOpacity: 1,
    cursor: 'pointer'
};

OpenLayers.Util.applyDefaults(mapfish.Routing.lastPointStyle,
                              OpenLayers.Feature.Vector.style['default']);

