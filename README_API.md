#MapWarper API Documentation

Welcome to the documentation for the MapWarper API!

##Authentication

Authentication for the MapWarper API is currently cookie-based.

**Curl Examples:**

```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/u/sign_in.json  -d '{"user" : { "email" : "tim@example.com", "password" : "password"}}' -c cookie

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET http://localhost:3000/maps.json -b cookie

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST --data '{"x":1, "y":2, "lat":123, "lon":22}'  http://localhost:3000/gcps/add/14.json -b cookie
```

##Search for Maps

###Basic Search

Example call:
```
GET[http://mapwarper.net/maps?field=title&amp;query=New&amp;sort_key=updated_at&amp;sort_order=desc&amp;show_warped=1&amp;format=json http://mapwarper.net/maps?field=title&query=New&sort_key=updated_at&sort_order=desc&show_warped=1&format=json]
```

#### Query Parameters

| Field Name       	| Description   							                  | Required |
| ------------- 	      |-------------							                  | -----|
| title      		| title of map; default if no field parameter is specified			| Optional |
| description		| map description      							            | Optional |
| nypl_digital_id 	| NYPL digital id, used for thumbnail and link to bibliographic extras	| Optional |
| catnyp 		      | NYPL digital catalog ID used to link to (library) record              | Optional |

**Query**       

Enter text for the search query, based on the field chosen. The query text is case insensitive.

      This is a simple exact string text search, i.e. a search for "city New York" gives no results, but a search for "city of New York" gives 22.

**Other Parameters**

| Name            | Value     | Description	|
| -------------   |---------- | -------------   |
| sort_key	      | title 	|	            |
| 		      | updated_at|	            |
|		      | status	|	            |
| sort_order	| asc 	|	            |
|		      | desc	|	            |
| show_warped	| 1		| 1 = only return maps that have already been warped |
| format	      | json	|                 |
| page		| 		| page number 	|

#### Output 

The output returned will be in JSON. It will be similar to the following.
```
{{{
{ "stat": "ok",
 "current_page": 1,
"items": [
   {
     "status": "warped",
     "map_type": "is_map",
     "updated_at": "2010/03/25 10:52:42 -0400",
    "title": "A chart of Delaware Bay and River : containing a full and exact description of the shores, creeks, harbours, soundings, shoals, sands, and bearings of the most considerable land marks \u0026c. \u0026c. / faithfully coppied [sic] from that published at Philadelphia",
     "id": 6985,
     "description": "from A new edition, much enlarged, of the second part of the North American pilot, for New England, New York, Pennsylvania, New Jersey, Maryland, Virginia, North and South Carolina, Georgia, Florida, and the Havanna : including general charts of the British Ch",
     "height": 4744,
     "nypl_digital_id": "1030125",
     "catnyp": "b7166511",
     "mask_status": null,
     "bbox": "-75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122",
     "width": 5875,
     "created_at": "2008/06/28 18:19:34 -0400"
   },

   {
     "status":
...

}],"total_pages":132,"per_page":10,"total_entries":1314}
}}}
```

###Geography-Based Map Search
This search uses a bounding box to return a paginated list of rectified/warped maps that either intersect or fall within a specified geographic area. The bounding box is defined by a comma-separated string.

**Parameter: bbox**

Format: 
```
     y.min (lon min) ,x.min (lat min) ,y.max (lon max), x.max (lat max)
```

Example: 
```
    -75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122
```
**Operation Parameters**  

| Name        | Description	|
| ------------- |-------------|
| intersect	| Preferred. Uses the PostGIS ST_Intersects operation to retrieve rectified maps whose extents intersect with the bbox parameter. Results are ordered by proximity to the bbox extent. |
| within	| Uses a PostGIS ST_Within operation to retrieve rectified maps that fall entirely within the extent of the bbox parameter. |

Format the query in JSON. 

Request Example:
```
[http://mapwarper.net/maps/geosearch?bbox=-74.4295114013431,39.71182637980763,-73.22376188967249,41.07147471270077&amp;format=json&amp;page=1&amp;operation=intersect

 http://mapwarper.net/maps/geosearch?bbox=-74.4295114013431,39.71182637980763,-73.22376188967249,41.07147471270077&format=json&page=1&operation=intersect]
```

####Response

The response will be similar to the following.
```
{{{
{"stat": "ok",
 "current_page": 1,
 "items": [
   {
     "updated_at": "2010/03/25 10:52:25 -0400",
     "title": "Map of the counties of Orange and Rockland / by David H. Burr ; engd. by Rawdon, Clark \u0026amp; Co., Albany, \u0026amp; Rawdon, Wright \u0026amp; Co., N. York.",
     "id": 12851,
     "description": "from An atlas of the state of New York : containing a map of the state and of the several counties / by David H. Burr.",
     "nypl_digital_id": "433847",
     "bbox": "-75.126810998457,40.7450450274136,-73.460790365527,41.843831161244"
   },
   {
     "updated_at": "2010/03/25 10:52:26 -0400",
......

}
 ],
 "total_pages": 61,
 "per_page": 20,
 "total_entries": 1206
}
}}}
```

###Retrieve a Map

You can retrieve a known map with the MapWarper API.

Request Example: 
```
GET[http://mapwarper.net/maps/8461.json http://mapwarper.net/maps/8461.json]

or [http://mapwarper.net/maps/8461?format=json http://mapwarper.net/maps/8461?format=json]
```

**Response Example:**

The output will be similar to the following:
```
{{{
{
 "stat": "ok",
 "items": [
   {
     "status": "warped",
     "map_type": "is_map",
     "updated_at": "2010/03/25 11:12:41 -0400",
   "title": "Double Page Plate No. 34: [Bounded by (New Town Creek) Commercial Street, Ash Street, Oakland Street, Paidge Avenue, Sutton Street, Meserole Avenue, Diamond Street, Calyer Street, Manhattan Avenue, Greenpoint Avenue, West Street and Bay Street.]",
     "id": 8461,
     "description": "from Atlas of the Brooklyn borough of the City of New York : originally Kings Co.; complete in three volumes ... based upon official maps and plans ... / by and under the supervision of Hugo Ullitz, C.E.",
     "height": 4920,
     "nypl_digital_id": "1517475",
     "catnyp": null,
     "mask_status": null,
     "bbox": "-73.9656432253048,40.7255401662787,-73.9405456042296,40.7411978079278",
     "width": 6299,
     "created_at": "2008/06/28 18:19:34 -0400"
   }
 ]
}
}}}
```

If the map is not found, the following response will be returned in JSON format.
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status


###Map Variables

| Name        	| Type		| Value		| Description					|
| ------------- |-------------	|-----		|-----						|
| title		| string 	|		|									|
| description	| string	|		|									|
| width		| integer	| 		| Width of unrectified image.					|
| height	| integer 	| 		      | Height of unrectified image.				|
| status	| integer	| 0 : unloaded	|  									|
| 		|		| 1 : loading 	| The master image is being requested from the NYPL repository.	|
| 		| 		| 2 : available	| The image has been copied, and is ready to be warped.	|
| 		| 		| 3 : warping	| The image is undergoing the warping process.			|
| 		| 		| 4 : warped	| The image has been rectified.					|
| 		| 		| 5 : published	| This status is set when the map should no longer be edited. Not currently used.|
| map_type	| integer 	| 0 : index	      | Indicates a map index or overview map.							|
| 		| 		| 1 : is_map	| Default map type. 										| 
| 		| 		| 2 : not_map	| Indicates non-map content, such as a plate depicting sea monsters.		|
| bbox	| string	| comma-separated string	| Coordinates for the bounding box of the rectified image.. Format: y.min (lon min) ,x.min (lat min) ,y.max (lon max), x.max (lat max).. Example: -75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122	|
| updated_at	| date	| 		| Date when the object was last updated.	|
| nypl_digital_id	| integer | 		| The NYPL digital id, which is used for thumbnails and links to bibliographic extras.		|
| catnyp_id	| integer	| 		| The NYPL digital catalog id used to link to the library record. 			|
| mask_status	| integer	| 		| Status of masking int.		|
| 		| 		| 0 : unmasked		| 				|
| 		| 		| 1 : masking		| 				|
| 		| 		| 2 : masked		| 				|


###Get Map Status
```
GET[http://mapwarper.net/maps/8991/status http://mapwarper.net/maps/8991/status]
```
This request returns text. If a map has no status (i.e., it has not been transferred yet), this request will return the status "loading".

This request is used to poll a map whilst it is being transfered from the NYPL image server to the map server. While this usually takes a few seconds, it could take several. Sometimes, the request does not succeed.


###Layers
####Query / List Layers
#####Query parameters

**Fields:**      

*Name (default).. 
*Description..
*catnyp..

**Query**        

Enter text for the search query, based on the field chosen. The query text is case insensitive.

      This is a simple exact string text search, i.e. a search for "city New York" retrieves no results, but a search for "city of New York" retrieves 22.

| Name            | Options	|
| -------------   | ----------- |
| sort_key	| name, depicts_year, updated_at, mapscans _count, or percent |
| sort_order	| asc or desc	|
| format	      | json		| 
| page		| page number 	|

Example:

[http://mapwarper.net/layers?field=name&amp;query=New+York&amp;format=json http://mapwarper.net/layers?field=name&query=New+York&format=json]

**Response**
```
{{{
{
 "current_page": 1,
 "items": [
   {
     "name": "Atlas of New York and vicinity : from actual surveys / by and under the direction of F. W. Beers, assisted by A. B. Prindle \u0026 others",
     "is_visible": true,
     "updated_at": "2010/02/25 11:09:33 -0500",
     "mapscans_count": 50,
     "id": 873,
     "rectified_mapscans_count": 9,
     "catnyp": "b5639903",
     "depicts_year": "1868",
     "bbox": "-73.949323,40.831269,-73.673187,41.300783",
     "created_at": "2009/03/23 21:21:19 -0400"
   },
   {
     "name":
............
}
 ],
 "total_pages": 6,
 "per_page": 20,
 "total_entries": 105
}
}}}
```

####Request a Map's Layers
To request a map's layers, use the map_id parameter. For example: 
```
[http://mapwarper.net/layers?map_id=10090&amp;field=name&amp;sort_key=mapscans_count&amp;sort_order=asc&amp;query=New&amp;format=json http://mapwarper.net/layers?map_id=10090&field=name&sort_key=mapscans_count&sort_order=asc&query=New&format=json]
```
Alternatively, the URL can be constructed from the point of view of a map:

http://mapwarper.net/maps/10090/layers.json

**Response**
```
{{{
{
 "stat": "ok",
"items": [
   {
     "name": "New topographical atlas of the counties of Albany and Schenectady, New York : from actual surveys / by S.N. \u0026 D.G. Beers and assistants.",
     "is_visible": true,
     "updated_at": "2009/10/12 19:47:13 -0400",
     "mapscans_count": 30,
     "id": 931,
     "rectified_mapscans_count": 20,
     "catnyp": "b5589358",
     "depicts_year": "1866",
     "bbox": "-74.433033,42.247915,-73.478985,43.136618",
     "created_at": "2009/03/23 21:21:19 -0400"
   },
   {
     "name": "New York",
     "is_visible": false,
     "updated_at": "2010/02/21 13:39:43 -0500",
     "mapscans_count": 2501,
     "id": 919,
     "rectified_mapscans_count": 96,
     "catnyp": null,
     "depicts_year": null,
     "bbox": "-83.179076,39.640270,-69.331971,45.723733",
     "created_at": "2009/03/23 21:21:19 -0400"
   }
 ]
}
}}}
```

If not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status

== Layer  ==
Get Layer:

gets a single layer.
```
[http://mapwarper.net/layers/760.json http://mapwarper.net/layers/760.js]on

or[http://mapwarper.net/layers/760?format=json http://mapwarper.net/layers/760?format=json]
```
**Response:**
```
{{{
{
 "stat": "ok",
 "items": [
   {
     "name": "America: being the latest, and most accurate description of the Nevv vvorld; containing the original of the inhabitants, and the remarkable voyages thither. The conquest of the vast empires of Mexico and Peru, and other large provinces and territories, wi",
     "is_visible": true,
     "updated_at": "2009/10/12 19:37:38 -0400",
     "mapscans_count": 115,
     "id": 760,
     "rectified_mapscans_count": 1,
     "catnyp": "b6082770",
     "depicts_year": "1671",
     "bbox": "-65.077269,32.107121,-64.553078,32.521725",
     "created_at": "2009/03/23 21:21:19 -0400"
   }
 ]
}
}}}
```

If not found, with format=json, the following response will be returned:
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status

Elements

bbox - bounding box, based on the extents of the tileindex shapefile that makes up the layer with maps.

mapscans_count - how many maps a layer has. Where a map is defined using the map_type => is_map variable - excludes title pages for instance.

rectified_mapscans_count - How many maps are rectified in the layer

percent - the percentage of rectified maps out of total number of maps

depicts_year - the year which this layer depicts

is_visible - boolean. if it's set to false, usually indicates a meta layer, or collection of atlases. These meta-layers will not have WMS.


== A Layer's Maps  ==
Returns paginated list of maps for a given layer.
```
[http://mapwarper.net/layers/maps/890?format=json&amp;show_warped=0 http://mapwarper.net/layers/890/maps?format=json&show_warped=]1

show_warped  0|1 (default is 1, only returns rectified maps, 0 show all maps)
```

==== Response  ====
JSON

```
{{{
{
 "stat": "ok",
 "current_page": 1,
 "items": [
   {
     "status": null,
     "map_type": "not_map",
     "updated_at": "2009/07/03 13:26:45 -0400",
     "title": "The generall historie of Virginia, New-England, and the Summer isles: with the names of the adventurers, planters, and governours from their first beginning ano: 1584. to this present 1626. With the proceedings of those severall colonies and the accident",
     "id": 12893,
     "description": "from The generall historie of Virginia, New-England, and the Summer isles : with the names of the adventurers, planters, and governours from their first beginning ano: 1584. to this present 1626. With the proceedings of those severall colonies and the accidents that befell them in all their journyes and discoveries. Also the maps and descriptions of all those countryes, their commodities, people, government, customes, and religion yet knowne. Divided into sixe bookes. / By Captaine Iohn Smith sometymes governour in those countryes \u0026 admirall of New England.",
     "height": null,
     "nypl_digital_id": "433895",
     "catnyp": null,
     "mask_status": null,
     "bbox": null,
     "width": null,
     "created_at": "2008/06/28 18:19:34 -0400"
   }
 ],

 "total_pages": 1,
 "per_page": 50,
 "total_entries": 1
}
}}}
```

== Map & Layer WMS  ==
=== Map WMS  ===
http://mapwarper.net/maps/wms/8561

=== Layer WMS  ===
http://mapwarper.net/layers/wms/931


== Map & Layer KML  ==
=== Map KML  ===
http://mapwarper.net/maps/8561.kml

=== Layer KML  ===
http://mapwarper.net/layers/931.kml

------------------------------

'''Ground Control Points'''

== Get a Maps Ground Control Points  ==
```
GET[http://mapwarper.net/maps/8561/gcps.json http://mapwarper.net/maps/8561/gcps.json]

or,[http://mapwarper.net/maps/8561/gcps?format=json http://mapwarper.net/maps/8561/gcps?format=json]
```
returns list of GCPs with calculated error.

=== Response  ===
==== JSON  ====
```
{{{
{
 "stat": "ok",
 "items": [
   {
     "lon": -73.960261342,
     "updated_at": "2008/08/08 07:38:27 -0400",
     "x": 5635.0,
     "y": 889.0,
     "mapscan_id": 8561,
     "id": 3489,
     "error": 2.12607673635957,
     "lat": 40.6903369015,
     "created_at": "2008/07/11 14:49:59 -0400"
   },
   {
     "lon": -73.934082982,
     "updated_at": "2008/08/08 07:38:27 -0400",
     "x": 4719.0,
     "y": 4014.0,
     "mapscan_id": 8561,
     "id": 3490,
     "error": 6.01964128034223,
     "lat": 40.6933793515,
     "created_at": "2008/07/11 14:49:59 -0400"
   },
....
 ]
}
}}}
```

If the map is not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status


==== fields  ====
x,y coordinates for unrectifed image

lat, lon coordinates to rectify to

mapscan_id - the map id

error - float, error for that point

'''Ground Control Points'''

'''with the following calls, if the GCP is not found, with format=json, the following response will be returned'''

'''{"items":[],"stat":"not found"} '''

'''with a HTTP 404 status'''


=== GCP - Get single point  ===
http://mapwarper.net/gcps/{gcp_id}?format=|json

http://mapwarper.net/gcps/9579?format=json


JSON

```
{{{
{
 "stat": "ok",
 "items": [
   {
     "lon": -5.6943786435,
     "updated_at": "2010/05/25 12:07:29 -0400",
     "x": 1544.54636904762,
     "y": 4892.97321428,
     "mapscan_id": 7449,
     "id": 9579,
     "lat": 50.1082502287,
     "created_at": "2009/03/06 14:23:44 -0500"
   }
 ]
}
}}}
```

=== GCP - add GCP  ===
Requires authentication
```
POST http://mapwarper.net/gcps/add/{map_id}
```
example 

http://mapwarper.net/gcps/add/7449

''where map_id is the map which wants a new gcp''

example with CURL
```
curl -X POST -d "x=1.1&y=2.3&format=json" -u name@example.com:password http://mapwarper.net/gcps/add/7449
```
'''params'''

Note, pass in the map id with this, sorry - this may change later!

 lat, lon, x, y are optional, if these are not present, the GCP is created with this missing value set as 0

 lat   lat of destination map (0 if not given)

 lon   lon of destination map (0 if not given)

 x    x of image (0 if not given)

 y      y of image (0 if not given)

 format   json



==== returns:  ====
==== JSON  ====
```
{{{
{
 "stat": "ok",
 "items": [
   {
     "lon": -73.960261342,
     "updated_at": "2008/08/08 07:38:27 -0400",
     "x": 5635.0,
     "y": 889.0,
     "mapscan_id": 8561,
     "id": 3489,
     "error": 2.12607673635957,
     "lat": 40.6903369015,
     "created_at": "2008/07/11 14:49:59 -0400"
   },
   {
     "lon": -73.934082982,
     "updated_at": "2008/08/08 07:38:27 -0400",
     "x": 4719.0,
     "y": 4014.0,
     "mapscan_id": 8561,
     "id": 3490,
     "error": 6.01964128034223,
     "lat": 40.6933793515,
     "created_at": "2008/07/11 14:49:59 -0400"
   },
...
 ]
}
}}}
```

==== Errors  ====
In case of an error, the output response would be similar as follows:
```

{{{
{
 "errors": [
  [
     "x",
     "is not a number"
   ]
 ],
 "stat": "fail",
"items": [],
 "message": "Could not add GCP"
}
}}}
```



=== GCP - Update entire GCP  ===
Requires authentication
```
PUT http://mapwarper.net/gcps/update/{gcp_id}
```
http://mapwarper.net/gcps/update/14803

where gcp_id is the id of the ground control point

example using CURL and HTTP BASIC
```
curl -X PUT -d "lat=54.33&lon=-1.467&x=3666.335&y=2000.12&format=json" -u user@example.com:password http://mapwarper.net/gcps/update/14803
```
 lat    lat of destination map

 lon    lon of destination map

 x     x of image

 y     y of image

 format  json



returns, list of GCPS, with error calculations (see above)



in case of error:

```
{{{
{"items":[],"errors":[["lat","is not a number"]],"stat":"fail","message":"Could not update GCP"}
}}}
```



=== GCP - Update one field of a GCP  ===
Requires authentication

PUT http://mapwarper.net/gcps/update_field/{gcp_id}

where gcp_id is the id of the ground control point

http://mapwarper.net/gcps/update_field/14803

params

attribute    lat|lon|x|y

value      value to change

format     json

returns list of GCPS, with error calculations (see above)

in case of error:

```
{{{
{"items":[],"errors":[["lat","is not a number"]],"stat":"fail","message":"Could not update GCP"}
}}}
```


=== GCP - Delete GCP  ===
Requires authentication
```
DELETE http://mapwarper.net/gcps/destroy/{gcp_id}
```
where gcp_id is the id of the ground control point

e.g. http://mapwarper.net/gcps/destroy/14805

params:

format   json

returns list of GCPS, with error calculations (see above)

in case of error:

```
{{{
{"items":[],"errors":[["field","message about field"]],"stat":"fail","message":"Could not delete GCP"}

}}}
```



== Cropping  ==
Requires authentication

uses GML to mask a portion of the map, so that areas on a map that are not masked become transparent.

=== Crop - Get mask  ===
```
GET http://mapwarper.net/shared/masks/{map_id}.gml.ol
```
http://mapwarper.net/shared/masks/7449.gml.ol

http://mapwarper.net/shared/masks/7449.gml.ol?1274110931 (with a timestamp to assist in browser cache busting)

gets a GML file, containing Polygons of the clipping mask

example:

```
{{{
<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1474.9689999999998,5425.602 3365.091,5357.612 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4493.725,1917.318 4072.187,1645.358 3079.533,1441.388 2467.623,1427.79 2304.447,1264.614 1529.3609999999999,1332.6039999999998 1542.9589999999998,1862.926 2005.291,2202.876 1624.547,2542.826 </nowiki><nowiki>1651.743,3195.53 1665.341,3698.656 1692.5369999999998,3997.812 2005.291,4201.782 2005.291,4419.35 1570.155,5140.044 1474.9689999999998,5425.602</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_201"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1447.773,4854.486 1828.5169999999998,4582.526 1950.899,4242.576 1774.125,4065.802 1583.753,3902.626 1610.949,3345.108 1597.3509999999999,2923.57 1447.773,2638.0119999999997 1379.783,2787.59 1338.989,4854.486 1447.773,4854.486</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>
}}}
```

=== Crop - Save mask  ===
Requires authentication
```
POST http://mapwarper.net/maps/{map_id}/save_mask
```
e.g. http://mapwarper.net/maps/7449/save_mask


with CURL
```

{{{
curl -X POST -d "format=json" -d 'output=<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>' -u user@example.com:pass  http://mapwarper.net/maps/7449/save_mask
}}}
```

params:

format  jsonoutput     a GML string containing for example:

```
{{{
<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>
}}}
```


Returns:

text string with a message indicating success or failure:
```
{"stat":"ok", "message":"Map clipping mask saved (gml)"}
```

=== Crop - Delete mask  ===
Requires authentication

deletes a maskPOST http://mapwarper.net/maps/{map_id}/delete_mask

params: format=json

returns string indicating success or failure i.e "mask deleted"
```
{"stat":"ok","message":"mask deleted"}
```
If the map is not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status


=== Crop - Mask map  ===
Requires authentication
```
POST http://mapwarper.net/maps/{map_id}/mask_map
```
applies the clipping mask to a map, but does not rectify it

A clipping mask should be saved before calling this.

Response:
```
{"stat":"ok","message":"Map cropped"}
```
If no clipping mask can be found,
```
{"stat":"fail","message":"Mask file not found"}
```

If the map is not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status


=== Crop - Save, Mask and Warp Map  ===
Requires authentication
```
POST http://mapwarper.net/maps/{map_id}/save_mask_and_warp
```
rolls the calls into one. Saves mask, applies mask to map, and rectifies map using the mask


params:

output - GML string containing polygon(s) to mask over (see save mask)


returns - text message indicating success,
```
{"stat":"ok","message":"Map masked and rectified!"}
```
in the case where a map has less than 3 Control Points, a message indicating that, whilst the mask was saved, and applied, the map needs more points to be able to rectify
```
{"stat":"ok","message":"Map masked but it needs more control points to rectify"}
```
If the map is not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status


== Warping  ==
Requires authentication

Warps or Rectifies a map according to its saved GCPs and the parameters passed in.
```
POST http://mapwarper.net/maps/{map_id}/rectify
```
e.g. http://mapwarper.net/maps/7449/rectify

with curl
```
curl -X POST -d "use_mask=false&format=json" -u email@example.com:password  http://mapwarper.net/maps/7449/rectify
```
params:

resample_options  (optional - nearest neighbour is given as default)

           near - Nearest Neighbour - fastest (default)

           bilinear - Binlinear interpolation

           cubic  - Cubic (good, slower)

           cubicspline - Cubic Spline slowest, best quality



transform_options  (optional - auto is given as default)

           auto (default)

           p1 - 1st Order Polynomial - min 3 points

           p2 - 2nd order polynomial - min 6 points

           p3 - 3rd order polynomial - min 10 points

           tps - Thin Plate Spline - (many points, evenly spread)



use_mask      true|false applies any saved mask to the map, optional, defaults to false


returns: if map is rectified
```
{"stat":"ok","message":"Map rectified."}
```
If the map hasnt got enough GCPS saved, the map won't be warped:
```
{"stat":"fail","message":"not enough GCPS to rectify"}
```
If the map is not found, with format=json, the following response will be returned
```
{"items":[],"stat":"not found"}
```
with a HTTP 404 status

