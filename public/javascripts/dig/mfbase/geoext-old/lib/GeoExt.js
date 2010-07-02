/* Copyright (C) 2008-2009 The Open Source Geospatial Foundation ¹
 * Published under the BSD license.
 * See http://geoext.org/svn/geoext/core/trunk/license.txt for the full text
 * of the license.
 * 
 * ¹ pending approval */

/*
 * The code in this file is based on code taken from OpenLayers.
 *
 * Copyright (c) 2006-2007 MetaCarta, Inc., published under the Clear BSD
 * license.  See http://svn.openlayers.org/trunk/openlayers/license.txt for the
 * full text of the license.
 */
 
(function() {

    /**
     * Check to see if GeoExt.singleFile is true. It is true if the
     * GeoExt/SingleFile.js is included before this one, as it is
     * the case in single file builds.
     */
    var singleFile = (typeof GeoExt == "object" && GeoExt.singleFile);

    /**
     * The relative path of this script.
     */
    var scriptName = singleFile ? "GeoExt.js" : "lib/GeoExt.js";

    /**
     * Function returning the path of this script.
     */
    var getScriptLocation = function() {
        var scriptLocation = "";
        var scripts = document.getElementsByTagName('script');
        for(var i=0, len=scripts.length; i<len; i++) {
            var src = scripts[i].getAttribute('src');
            if(src) {
                var index = src.lastIndexOf(scriptName); 
                // set path length for src up to a query string
                var pathLength = src.lastIndexOf('?');
                if(pathLength < 0) {
                    pathLength = src.length;
                }
                // is it found, at the end of the URL?
                if((index > -1) && (index + scriptName.length == pathLength)) {
                    scriptLocation = src.slice(0, pathLength - scriptName.length);
                    break;
                }
            }
        }
        return scriptLocation;
    };

    /**
     * If GeoExt.singleFile is false then the JavaScript files in the jsfiles
     * array are autoloaded.
     */
    if(!singleFile) {
        var jsfiles = new Array(
            "GeoExt/data/FeatureRecord.js",
            "GeoExt/data/FeatureReader.js",
            "GeoExt/data/FeatureStore.js",
            "GeoExt/data/LayerRecord.js",
            "GeoExt/data/LayerReader.js",
            "GeoExt/data/LayerStore.js",
            "GeoExt/data/ScaleStore.js",
            "GeoExt/data/WMSCapabilitiesReader.js",
            "GeoExt/data/WMSCapabilitiesStore.js",
            "GeoExt/data/ProtocolProxy.js",
            "GeoExt/widgets/MapPanel.js",
            "GeoExt/widgets/Popup.js"
        );

        var agent = navigator.userAgent;
        var docWrite = (agent.match("MSIE") || agent.match("Safari"));
        if(docWrite) {
            var allScriptTags = new Array(jsfiles.length);
        }
        var host = getScriptLocation() + "lib/";    
        for (var i=0, len=jsfiles.length; i<len; i++) {
            if (docWrite) {
                allScriptTags[i] = "<script src='" + host + jsfiles[i] +
                                   "'></script>"; 
            } else {
                var s = document.createElement("script");
                s.src = host + jsfiles[i];
                var h = document.getElementsByTagName("head").length ? 
                           document.getElementsByTagName("head")[0] : 
                           document.body;
                h.appendChild(s);
            }
        }
        if (docWrite) {
            document.write(allScriptTags.join(""));
        }
    }
})();
