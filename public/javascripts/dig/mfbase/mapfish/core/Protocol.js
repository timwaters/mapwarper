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

/**
 * Namespace: mapfish.Protocol
 * Contains convenience methods for protocol manipulation.
 */
mapfish.Protocol = {

    /**
     * APIFunction: decorateProtocol
     * Decorate a protocol.
     *
     * Example of use:
     * (start code)
     * var protocol = mapfish.Protocol.decorateProtocol({
     *     protocol: protocol,
     *     TriggerEventDecorator: {
     *         eventListeners: {
     *             crudfinished: function() {
     *                 alert("CRUD operation completed");
     *             }
     *         }
     *     },
     *     MergeFilterDecorator: null
     * });
     * (end)
     *
     * Parameters:
     * config - {Object} Config object specifying how protocol must be
     *     decorated, see the above the example.
     *
     * Returns:
     * {<OpenLayers.Protocol>} The resulting protocol.
     * */
    decorateProtocol: function(config) {
        var protocol = config.protocol;
        for (var key in config) {
            if (key != "protocol") {
                if (!mapfish.Protocol[key]) {
                    OpenLayers.Console.error(
                        "mapfish.Protocol." + key + " does not exist");
                } else {
                    protocol = new mapfish.Protocol[key](
                        OpenLayers.Util.extend(
                            {protocol: protocol}, config[key])
                    );
                }
            }
       }
       return protocol;
    },

    /**
     * APIFunction: createMapFishProtocol
     * Shortcut to create MapFish Protocol decorated with TriggerEventDecorator
     *     and MergeFilterDecorator
     *
     * Example of use:
     * (start code)
     * var protocol = mapfish.Protocol.createMapFishProtocol({
     *     url: url,
     * });
     * (end)
     *
     * Parameters:
     * config - {Object} The config of the decorated MapFish protocol
     *
     * Returns:
     * {<mapfish.Protocol.MapFish>} The resulting protocol.
     * */
    createMapFishProtocol: function(config) {
        return this.decorateProtocol({
            protocol: new mapfish.Protocol.MapFish(config),
            MergeFilterDecorator: null,
            TriggerEventDecorator: null
        });
    }
    
};
