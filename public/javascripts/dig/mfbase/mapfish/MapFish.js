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

/*
 * This code is taken from the OpenLayers code base.
 *
 * Copyright (c) 2006-2007 MetaCarta, Inc., published under the Clear BSD
 * license.  See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license.
 */

(function() {
    /**
     * Before creating the mapfish namespace, check to see if
     * mapfish.singleFile is true. This occurs if the
     * SingleFile.js script is included before this one - as is the
     * case with single file builds.
     */
    var singleFile = (typeof window.mapfish == "object" && window.mapfish.singleFile);

    /**
     * Namespace: mapfish
     * The mapfish object provides a namespace for all things 
     */
    window.mapfish = {

        /**
         * Property: _scriptName
         * {String} Relative path of this script.
         */
        _scriptName: "MapFish.js",

        /**
         * Function: _getScriptLocation
         * Return the path to this script.
         *
         * Returns:
         * Path to this script
         */
        _getScriptLocation: function () {
            // Workaround for Firefox bug:
            // https://bugzilla.mozilla.org/show_bug.cgi?id=351282
            if (window.gMfLocation) {
                return window.gMfLocation;
            }

            var scriptLocation = "";
            var scriptName = mapfish._scriptName;
         
            var scripts = document.getElementsByTagName('script');
            for (var i = 0; i < scripts.length; i++) {
                var src = scripts[i].getAttribute('src');
                if (src) {
                    var index = src.lastIndexOf(scriptName); 
                    // is it found, at the end of the URL?
                    if ((index > -1) && (index + scriptName.length == src.length)) {  
                        scriptLocation = src.slice(0, -scriptName.length);
                        break;
                    }
                }
            }
            return scriptLocation;
         }
    };

    /**
     * mapfish.singleFile is a flag indicating this file is being included
     * in a Single File Library build of the MapFish Library.
     * 
     * When we are *not* part of a SFL build we dynamically include the
     * MapFish library code.
     * 
     * When we *are* part of a SFL build we do not dynamically include the 
     * MapFish library code as it will be appended at the end of this file.
      */
    if(!singleFile) {
        var jsfiles = new Array(
            "lang/en.js",
            "core/Color.js",
            "core/GeoStat.js",
            "core/GeoStat/Choropleth.js",
            "core/GeoStat/ProportionalSymbol.js",
            "core/Routing.js",
            "core/Util.js",
            "core/Searcher.js",
            "core/Searcher/Map.js",
            "core/Searcher/Form.js",
            "core/PrintProtocol.js",
            "core/Offline.js",
            "core/Protocol.js",
            "core/Protocol/MapFish.js",
            "core/Protocol/MergeFilterDecorator.js",
            "core/Protocol/TriggerEventDecorator.js",
            "core/Strategy.js",
            "core/Strategy/ProtocolListener.js",
            "widgets/MapComponent.js",
            "widgets/Shortcuts.js",
            "widgets/ComboBoxFactory.js",
            "widgets/recenter/Base.js",
            "widgets/recenter/Coords.js",
            "widgets/data/FeatureReader.js",
            "widgets/data/FeatureStore.js",
            "widgets/data/FeatureStoreMediator.js",
            "widgets/data/SearchStoreMediator.js",
            "widgets/data/LayerStoreMediator.js",
            "widgets/data/GridRowFeatureMediator.js",
            "widgets/geostat/Choropleth.js",
            "widgets/geostat/ProportionalSymbol.js",
            "widgets/tree/LayerTree.js",
            "widgets/tree/LayerTreeExtra.js",
            "widgets/toolbar/Toolbar.js",
            "widgets/toolbar/CheckItem.js",
            "widgets/toolbar/MenuItem.js",
            "widgets/editing/FeatureList.js",
            "widgets/editing/FeatureProperties.js",
            "widgets/editing/FeatureEditingPanel.js",
            "widgets/print/Base.js",
            "widgets/print/BaseWidget.js",
            "widgets/print/SimpleForm.js",
            "widgets/print/MultiPage.js",
            "widgets/print/PrintAction.js"
        ); // etc.

        var allScriptTags = "";
        var host = mapfish._getScriptLocation();
    
        for (var i = 0; i < jsfiles.length; i++) {
            if (/MSIE/.test(navigator.userAgent) || /Safari/.test(navigator.userAgent)) {
                var currentScriptTag = "<script src='" + host + jsfiles[i] + "'></script>"; 
                allScriptTags += currentScriptTag;
            } else {
                var s = document.createElement("script");
                s.src = host + jsfiles[i];
                var h = document.getElementsByTagName("head").length ? 
                           document.getElementsByTagName("head")[0] : 
                           document.body;
                h.appendChild(s);
            }
        }
        if (allScriptTags) {
            document.write(allScriptTags);
        }
    }
})();
