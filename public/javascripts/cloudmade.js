OpenLayers.Layer.CloudMade = OpenLayers.Class(OpenLayers.Layer.TMS, {
    initialize: function(name, options) {
		if (!options.key) {
			throw "Please provide key property in options (your API key).";
		}
        options = OpenLayers.Util.extend({
            attribution: "Data &copy; 2009 <a href='http://openstreetmap.org/'>OpenStreetMap</a>. Rendering &copy; 2009 <a href='http://cloudmade.com'>CloudMade</a>.",
            maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),
            maxResolution: 156543.0339,
            units: "m",
            projection: "EPSG:900913",
			isBaseLayer: true,
			numZoomLevels: 19,
			displayOutsideMaxExtent: true,
			wrapDateLine: true,
			styleId: 1
        }, options);
		var prefix = [options.key, options.styleId, 256].join('/') + '/';
        var url = [
            "http://a.tile.cloudmade.com/" + prefix,
            "http://b.tile.cloudmade.com/" + prefix,
            "http://c.tile.cloudmade.com/" + prefix
        ];
        var newArguments = [name, url, options];
        OpenLayers.Layer.TMS.prototype.initialize.apply(this, newArguments);
    },

    getURL: function (bounds) {
        var res = this.map.getResolution();
        var x = Math.round((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
        var y = Math.round((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
        var z = this.map.getZoom();
        var limit = Math.pow(2, z);

        if (y < 0 || y >= limit)
        {
            return "http://cloudmade.com/js-api/images/empty-tile.png";
        }
        else
        {
            x = ((x % limit) + limit) % limit;

            var url = this.url;
            var path = z + "/" + x + "/" + y + ".png";

            if (url instanceof Array)
            {
                url = this.selectUrl(path, url);
            }

            return url + path;
        }
    },

    CLASS_NAME: "OpenLayers.Layer.CloudMade"
});