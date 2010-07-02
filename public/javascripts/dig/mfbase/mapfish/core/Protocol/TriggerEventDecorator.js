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
 * @requires OpenLayers/Util.js
 * @requires OpenLayers/Protocol.js
 */

/**
 * Class: mapfish.Protocol.TriggerEventDecorator
 * Decorator class responsible to trigger events when requests are
 * sent and received.
 *
 * Inherits from:
 * - <OpenLayers.Protocol>
 */

mapfish.Protocol.TriggerEventDecorator = OpenLayers.Class(OpenLayers.Protocol, {

    /**
     * APIProperty: protocol
     * {<OpenLayers.Protocol>} The decorated protocol.
     */
    protocol: null,

    /**
     * Property: events
     * {<OpenLayers.Events>}
     */
    events: null,

    /**
     * Constant: EVENT_TYPES
     * {Array(String)} Supported event types. Register a listener
     *     for a particular event with the following syntax:
     *
     * (start code)
     * protocol.events.register(type, obj, listener);
     * (end)
     *
     * Listeners will be called with a reference to an event object.
     *
     * Supported events:
     * - *crudtriggered* Triggered when either "create", "read", "update"
     *     or "delete" is called, listeners will receive an object with
     *     a type property referencing either the string "create",
     *     "read", "update", or "delete" depending on what type of
     *     CRUD operation is actually triggered.
     * - *crudfinished* Triggered when either "create", "read", "update"
     *     or "delete" is finished, listeners will receive an
     *     <OpenLayers.Protocol.Response> object.
     * - *committriggered* Triggered when a commit operation is triggered.
     * - *commitfinished* Triggered when a commit operation is finished.
     * - *clear* Triggered when the clear API method is called.
     */
    EVENT_TYPES: ["crudtriggered", "crudfinished",
                  "committriggered", "commitfinished",
                  "clear"],

    /**
     * Constructor: mapfish.Protocol.TriggerEventDecorator
     *
     * Parameters:
     * options - {Object} Optional parameters to set in the protocol.
     *
     * Returns:
     * {<mapfish.Protocol.TriggerEventDecorator>}
     */
    initialize: function(options) {
        OpenLayers.Protocol.prototype.initialize.call(this, options);
        this.events = new OpenLayers.Events(this, null, this.EVENT_TYPES);
        if (this.eventListeners instanceof Object) {
            this.events.on(this.eventListeners);
        }
    },

    /**
     * APIMethod: read
     * Construct a request for reading new features.
     *
     * Parameters:
     * options - {Object} Optional object for configuring the request.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     * object, the same object will be passed to the callback function passed
     * if one exists in the options object.
     */
    read: function(options) {
        var newOptions = OpenLayers.Util.applyDefaults({
            callback: this.createCallback(this.handleCRUD, options),
            scope: null
        }, options);
        this.events.triggerEvent("crudtriggered", {type: "read"});
        return this.protocol.read(newOptions);
    },
    
    
    /**
     * APIMethod: create
     * Construct a request for writing newly created features.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})} or
     *            {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     * object, the same object will be passed to the callback function passed
     * if one exists in the options object.
     */
    create: function(features, options) {
        var newOptions = OpenLayers.Util.applyDefaults({
            callback: this.createCallback(this.handleCRUD, options),
            scope: null
        }, options);
        this.events.triggerEvent("crudtriggered", {type: "create"});
        return this.protocol.create(features, newOptions);
    },
    
    /**
     * APIMethod: update
     * Construct a request updating modified features.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})} or
     *            {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     * object, the same object will be passed to the callback function passed
     * if one exists in the options object.
     */
    update: function(features, options) {
        var newOptions = OpenLayers.Util.applyDefaults({
            callback: this.createCallback(this.handleCRUD, options),
            scope: null
        }, options);
        this.events.triggerEvent("crudtriggered", {type: "update"});
        return this.protocol.update(features, newOptions);
    },
    
    /**
     * APIMethod: delete
     * Construct a request deleting a removed feature.
     *
     * Parameters:
     * feature - {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     * object, the same object will be passed to the callback function passed
     * if one exists in the options object.
     */
    "delete": function(feature, options) {
        var newOptions = OpenLayers.Util.applyDefaults({
            callback: this.createCallback(this.handleCRUD, options),
            scope: null
        }, options);
        this.events.triggerEvent("crudtriggered", {type: "delete"});
        return this.protocol["delete"](feature, newOptions);
    },

    /**
     * APIMethod: commit
     * Go over the features and for each take action
     * based on the feature state. Possible actions are create,
     * update and delete.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})}
     * options - {Object} Object whose possible keys are "create", "update",
     *      "delete", "callback" and "scope", the values referenced by the
     *      first three are objects as passed to the "create", "update", and
     *      "delete" methods, the value referenced by the "callback" key is
     *      a function which is called when the commit operation is complete
     *      using the scope referenced by the "scope" key.
     *
     * Returns:
     * {Array({<OpenLayers.Protocol.Response>})} An array of
     * <OpenLayers.Protocol.Response> objects.
     */
    commit: function(features, options) {
        var newOptions = OpenLayers.Util.applyDefaults({
            callback: this.createCallback(this.handleCommit, options),
            scope: null
        }, options);
        this.events.triggerEvent("committriggered");
        return this.protocol.commit(features, newOptions);
    },

    /**
     * Method: abort
     * Abort an ongoing request.
     *
     * Parameters:
     * response - {<OpenLayers.Protocol.Response>}
     */
    abort: function(response) {
        this.protocol.abort(response);
    },

    /**
     * Method: createCallback
     * Returns a function that applies the given public method with the
     * options argument.
     *
     * Parameters:
     * method - {Function} The method to be applied by the callback.
     * options - {Object} Options sent to the protocol method (read, create,
     *     update, or delete).
     */
    createCallback: function(method, options) {
        return OpenLayers.Function.bind(method, this, options);
    },

    /**
     * Method: handleCRUD
     * Method used to handle "create", "read", "update", and "delete"
     * operations.
     *
     * Parameters:
     * options - {Object} Options sent to the protocol method (read, create,
     *     update, or delete).
     * response - {<OpenLayers.Protocol.Response>} Response object received
     *     from the underlying protocol.
     */
    handleCRUD: function(options, response) {
        if (options && options.callback) {
            options.callback.call(options.scope, response);
        }
        this.events.triggerEvent("crudfinished", response);
    },

    /**
     * Method: handleCommit
     * Method used to handle "commit" operations.
     *
     * Parameters:
     * options -  {Object} Options sent to the protocol commit method.
     */
    handleCommit: function(options) {
        if (options.callback) {
            options.callback.call(options.scope);
        }
        this.events.triggerEvent("commitfinished");
    },

    /**
     * APIMethod: clear
     *      Clear all the previous results.
     */
    clear: function() {
        this.events.triggerEvent("clear");
    },

    CLASS_NAME: "mapfish.Protocol.TriggerEventDecorator"
});
