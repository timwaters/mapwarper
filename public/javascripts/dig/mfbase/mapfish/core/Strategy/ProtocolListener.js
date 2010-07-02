/*
 * Copyright (C) 2007  Camptocamp
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

/*
 * @requires OpenLayers/Strategy.js
 * @requires core/Strategy.js
 */

/**
 * Class: mapfish.Strategy.ProtocolListener
 * A strategy that listens to "crudfinished" and "clear" events triggered
 * by a <mapfish.Protocol.TriggerEventDecorator> protocol, upon receiving
 * a "crudfinished" event and if the request is of type "read", the
 * strategy adds the received features to the layer, upon receiving a
 * "clear" event, the strategy destroys the features in the layer. A
 * <mapfish.Protocol.TriggerEventDecorator> protocol must be
 * configured in the layer for this strategy to work as expected.
 *
 * Example usage:
 * (start code)
 * var layer = new OpenLayers.Layer.Vector(
 *     "some layer name", {
 *         protocol: new mapfish.Protocol.TriggerEventDecorator(someProtocol),
 *         strategies: [new mapfish.Strategy.ProtocolListener({append: true})]
 *     }
 * );
 * (end)
 *
 * Inherits from:
 *  - <OpenLayers.Strategy>
 */
mapfish.Strategy.ProtocolListener = OpenLayers.Class(OpenLayers.Strategy, {

    /**
     * APIProperty: append
     * {Boolean} If false, existing layer features are destroyed
     *     before adding newly read features. Defaults to false.
     */
    append: false,

    /**
     * APIProperty: recenter
     * {Boolean} If true, map is recentered to features extent.
     *     Defaults to false.
     */
    recenter: false,

    /**
     * Constructor: mapfish.Strategy.ProtocolListener
     * Create a new ProtocolListener strategy.
     *
     * Parameters:
     * options - {Object} Optional object whose properties will be set on the
     *     instance.
     */
    initialize: function(options) {
        OpenLayers.Strategy.prototype.initialize.apply(this, [options]);
    },

    /**
     * Method: activate
     * Set up strategy with regard to adding features to the layer when
     * receiving crudfinished events and destroying the layer features
     * when receiving clear events.
     *
     * Returns:
     * {Boolean} The strategy was successfully activated.
     */
    activate: function() {
        if (this.layer.protocol.CLASS_NAME != "mapfish.Protocol.TriggerEventDecorator") {
            OpenLayers.Console.error([
                "This strategy is to be used with a layer whose protocol ",
                "is an instance of mapfish.Protocol.TriggerEventDecorator"].join('')
            );
            return false;
        }
        var activated = OpenLayers.Strategy.prototype.activate.call(this);
        if (activated) {
            this.layer.protocol.events.on({
                "crudfinished": this.onCrudfinished,
                "clear": this.onClear,
                scope: this
            });
        }
        return activated;
    },

    /**
     * Method: deactivate
     * Tear down strategy.
     *
     * Returns:
     * {Boolean} The strategy was successfully deactivated.
     */
    deactivate: function() {
        var deactivated = OpenLayers.Strategy.prototype.deactivate.call(this);
        if (deactivated) {
            this.layer.protocol.events.un({
                "crudfinished": this.onCrudfinished,
                "clear": this.onClear,
                scope: this
            });
        }
        return deactivated;
    },

    /**
     * Method: onCrudfinished
     * Callback function called on protocol crudfinished event.
     *
     * Parameters:
     * options - {<OpenLayers.Response>} Protocol response
     */
    onCrudfinished: function(response) {
        if (response.requestType == "read") {
            this.addFeatures(response.features);
        }
    },

    /**
     * Method: addFeatures
     * Adds the read features to the layer
     *
     * Parameters:
     * options - {<OpenLayers.Response>} Protocol response
     */
    addFeatures: function(features) {
        if (!this.append) {
            this.layer.destroyFeatures();
        }
        if (features && features.length > 0) {
            this.layer.addFeatures(features);
            if (this.recenter) {
                this.layer.map.zoomToExtent(this.layer.getDataExtent());
            }
        }
    },

    /**
     * Method: onClear
     * Callback function called on protocol clear event.
     */
    onClear: function() {
        this.layer.destroyFeatures();
    },

    CLASS_NAME: "mapfish.Strategy.ProtocolListener"
});