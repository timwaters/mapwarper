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
 * @requires OpenLayers/Filter/Comparison.js
 * @requires OpenLayers/Filter/Logical.js
 * @requires core/Searcher.js
 */

/**
 * Class: mapfish.Protocol.MergeFilterDecorator
 * Instances of this class decorate a protocol by merging filters provided
 * by searchers before invoking the decorated protocol's read method.
 * 
 * Inherits from:
 * - <OpenLayers.Protocol>
 */

mapfish.Protocol.MergeFilterDecorator = OpenLayers.Class(OpenLayers.Protocol, {
    /**
     * Property: searchers
     * Array({<mapfish.Searcher>} Array of searchers from which the merge
     *     filter decorator gets filters.
     */
    searchers: null,

    /**
     * APIProperty: protocol
     * {<OpenLayers.Protocol>} The decorated protocol.
     */
    protocol: null,

    /**
     * Constructor: mapfish.Protocol.MergeFilterDecorator
     *
     * Parameters:
     * options - {Object}
     */
    initialize: function(options) {
        this.searchers = [];
        OpenLayers.Protocol.prototype.initialize.call(this, options);
    },

    /**
     * APIMethod: register
     * Register a searcher.
     */
    register: function(searcher) {
        this.searchers.push(searcher);
    },

    /**
     * APIMethod: unregister
     * Unregister a searcher.
     */
    unregister: function(searcher) {
        OpenLayers.Util.removeItem(searcher, this.searchers);
    },

    /**
     * APIMethod: create
     * Create features, this method does nothing more than calling
     * the decorator protocol's create method.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})} or
     *            {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *     This object is modified and should not be reused.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     *      object, this object is also passed to the callback function when 
     *      the request completes.
     */
    "create": function(features, options) {
        return this.protocol.create(features, options);
    },

    /**
     * APIMethod: read
     * Merge filters provided by searchers, and call the decorated
     * protocol's read method, passing it the merged filter.
     *
     * Parameters:
     * options - {Object} Optional object for configuring the request.
     *     This object is modified and should not be reused.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     *      object, this object is also passed to the callback function when
     *      the request completes.
     */
    "read": function(options) {
        options.filter = this.mergeFilters(
            options.filter || options.params, options.searcher);
        delete options.searcher;
        return this.protocol.read(options);
    },

    /**
     * Method: mergeFilters
     * Merge filters provided by searchers.
     *
     * Parameters:
     * filter - {<OpenLayers.Filter>}|{Object}
     * searcher - {<mapfish.Searcher>}
     *
     * Returns:
     * {<OpenLayers.Filter>} The resulting filter.
     */
    mergeFilters: function(filter, searcher) {
        var i, len, s;
        // ensure that filter is an OpenLayers.Filter instance
        if (filter && !this.isFilter(filter)) {
            filter = this.fromObjToFilter(filter);
        }
        for (i = 0, len = this.searchers.length; i < len; i++) {
            s = this.searchers[i];
            if (s != searcher) {
                filter = this.toFilter(s.getFilter(), filter);
            }
        }
        return filter;
    },

    /**
     * Method: toFilter
     *
     * Parameters:
     * obj - {Object}
     * filter - {<OpenLayers.Filter>}
     *
     * Returns:
     * {<OpenLayers.Filter.Logical>}
     */
    toFilter: function(obj, filter) {
        if (!obj) {
            return filter;
        }
        if (!filter) {
            filter = new OpenLayers.Filter.Logical({
                type: OpenLayers.Filter.Logical.AND
            });
        } else if (!this.isLogicalFilter(filter)) {
            filter = new OpenLayers.Filter.Logical({
                type: OpenLayers.Filter.Logical.AND,
                filters: [filter]
            });
        }
        var filters = filter.filters;
        if (this.isFilter(obj)) {
            filters.push(obj);
        } else {
            filters.push(this.fromObjToFilter(obj));
        }
        return filter;
    },

    /**
     * Method: fromObjToFilter
     *
     * Paremeters:
     * obj - {Object}
     *
     * Returns:
     * {<OpenLayers.Filter.Logical>}
     */
    fromObjToFilter: function(obj) {
        var filters = [];
        for (var key in obj) {
            filters.push(
                new OpenLayers.Filter.Comparison({
                    type: OpenLayers.Filter.Comparison.EQUAL_TO,
                    property: key,
                    value: obj[key]
                })
            );
        }
        return new OpenLayers.Filter.Logical({
            type: OpenLayers.Filter.Logical.AND,
            filters: filters
        });
    },

    /**
     * Method: isLogicalFilter
     * Check if the object passed is a <OpenLayers.Filter.Logical> object.
     *
     * Parameters:
     * obj - {Object}
     *
     * Returns:
     * {Boolean}
     */
    isLogicalFilter: function(obj) {
        return !!obj.CLASS_NAME &&
               !!obj.CLASS_NAME.match(/^OpenLayers\.Filter\.Logical/);
    },

    /**
     * Method: isFilter
     * Check if the object passed is a <OpenLayers.Filter> object.
     *
     * Parameters:
     * obj - {Object}
     *
     * Returns:
     * {Boolean}
     */
    isFilter: function(obj) {
        return !!obj.CLASS_NAME &&
               !!obj.CLASS_NAME.match(/^OpenLayers\.Filter/);
    },

    /**
     * APIMethod: update
     * Update features, this method does nothing more than calling
     * the decorator protocol's update method.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})} or
     *            {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *     This object is modified and should not be reused.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     *      object, this object is also passed to the callback function when 
     *      the request completes.
     */
    "update": function(features, options) {
        return this.protocol.update(features, options);
    },

    /**
     * APIMethod: delete
     * Delete features, this method does nothing more than calling
     * the decorator protocol's delete method.
     *
     * Parameters:
     * features - {Array({<OpenLayers.Feature.Vector>})} or 
     *            {<OpenLayers.Feature.Vector>}
     * options - {Object} Optional object for configuring the request.
     *     This object is modified and should not be reused.
     *
     * Returns:
     * {<OpenLayers.Protocol.Response>} An <OpenLayers.Protocol.Response>
     *      object, this object is also passed to the callback function when 
     *      the request completes.
     */
    "delete": function(features, options) {
        return this.protocol["delete"](features, options);
    },

    /**
     * Method: commit
     * Commit created, updated and deleted features, this method does nothing
     * more than calling the decorated protocol's commit method.
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
        return this.protocol.commit(features, options);
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

    CLASS_NAME: "mapfish.Protocol.MergeFilterDecorator"
});
