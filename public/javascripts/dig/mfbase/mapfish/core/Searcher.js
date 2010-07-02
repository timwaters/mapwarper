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
 * Class: mapfish.Searcher
 * Base searcher class. This class is not meant to be used directly, it serves
 * as a base class for specific searcher implementations.
 */
mapfish.Searcher = OpenLayers.Class({
        
    /**
     * Constructor: mapfish.Searcher
     *
     * Returns:
     * {<mapfish.Searcher>}
     */
    initialize: function() {},

    /**
     * Method: getFilter
     * Get the search filter.
     * This should be overridden by specific subclasses
     *
     * Returns:
     * {<OpenLayers.Filter>}
     */
    getFilter: function() {},

    CLASS_NAME: "mapfish.Searcher"
});
