#MapWarper API Documentation

Welcome to the documentation for the MapWarper API!

[Search for Maps](#search-for-maps)

##Authentication

Authentication for the MapWarper API is currently cookie-based.

**cURL Examples**

```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST http://localhost:3000/u/sign_in.json  -d '{"user" : { "email" : "tim@example.com", "password" : "password"}}' -c cookie

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET http://localhost:3000/maps.json -b cookie

curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST --data '{"x":1, "y":2, "lat":123, "lon":22}'  http://localhost:3000/gcps/add/14.json -b cookie
```

##[search-for-maps](Search for Maps)

###Basic Search

| Method        | 
| ------------- | 
| GET           |  

Returns a list of maps that meet search criteria. 

**Parameters**

| Name      	    |             | Type  | Description  |  Required | Notes  |
| -----          | -----       | ----- | ---------        |  -----    | ------ |
| title      		  |              	|string  | the title of the map   | optional | default |
| description		  |               | string | the escription of the map | optional |       |
| nypl_digital_id 	| 	         | integer  | the NYPL digital id used for the thumbnail image and link to the library's metadata | optional | |
| catnyp 		      |             | integer  | the NYPL digital catalog ID used to link to the library record              | optional | |
| sort_key	             	      ||         | the field on which the sort should be based  | optional |   |
| 		              | title     | string    | the title of the map	             | optional            | |
| 		              | updated_at|           | when the map was last updated	| optional            | |
|		               | status	   | integer   | the status of the map	            | optional            | gives the number of control points for a warped image, or the status "unrectified" |
| sort_order	                 ||  string  | the order in which the items returned should appear | optional            | |
|                 | asc 	     | string    | ascending order               | optional            | |
|		               | desc	     | string    | descending order              | optional            | |
| show_warped	    | 		        | integer   | limits to maps that have already been warped   | optional | Use "1" | 
| format	         |     	     | string    | 
can be used to request “json” output, rather than HTML or XML   | optional            | default is HTML |
| page		          | 		        | integer   | the page number; use to get the next or previous page  | optional            | |

Enter optional text for the search query, based on the field chosen. The query text is case insensitive. This is a simple exact string text search. For example, a search for "city New York" returns no results, but a search for "city of New York" returns 22.

**Example Call**

[http://mapwarper.net/maps?field=title&query=New&sort_key=updated_at&sort_order=desc&show_warped=1&format=json](http://mapwarper.net/maps?field=title&query=New&sort_key=updated_at&sort_order=desc&show_warped=1&format=json)

**Response**

The response will be in JSON in the following format.
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

###Response Elements

| Name        	 |               | Type	   | Value		         | Description					| Notes |
| ------------- |-------------	 | -----		 |-----------						| --------------  | ----  |
| stat		        |               | string 	|		               | the status of the request		|    |
| current_page		|               | integer |		               | indicates on which page of the search results the map appears		|    |
| items		       |               | an array of key pairs with information about the map 	|		|									| |
|               | status	       | integer	 | 	              | the status of the map     |  | 
| 		            | 		            |          | 0 : unloaded	  | the map has not been loaded					       | |
| 		            |		             |          | 1 : loading 	  | the master image is being requested from the NYPL repository	 |    |
| 		            | 		            |          | 2 : available	 | the map has been copied and is ready to be warped	|  |
| 		            | 		            |          | 3 : warping	   | the map is undergoing the warping process			|  |
| 		            | 		            |          | 4 : warped	    | the map has been warped					|  |
| 		            | 		            |          | 5 : published	 | this status is set when the map should no longer be edited | not currently used |
|               | map_type	     | integer 	|          	      | indicates whether the image is of a map or another type of content	| |
|               |         	     |         	| 0 : index	      | indicates a map index or overview map							| |
| 		            | 		            |          | 1 : is_map	     |  										| default |
| 		            | 	 	           |          | 2 : not_map	    | indicates non-map content, such as a plate depicting sea monsters		| |
|               | updated_at	   | string	  | describes when the map was last updated		| e.g., "5 days ago."	|
|               | title		       | string 	 |		|		the title of the map							| |
|               | id		          | integer 	|		|		the unique identifier for the map						| |
|               | description	  | string	  |		|		the description of the map							| |
|               | height	       | integer 	| 	|  the height of an unwarped map				| |
|               | nypl_digital_id	| integer |	|  the NYPL digital ID, which is used for thumbnail images and links to thelibrary metadata		| |
|               | catnyp_id	    | integer	 || the NYPL digital catalog that is used to link to the library record 			| |
|               | mask_status	  | integer	 || the status of the mask		| |
| 		            | 		            |          | 0 : unmasked		| the map has not been masked				| |
| 		            | 		            |          | 1 : masking		 | the map is undergoing the masking process				| |
| 		            | 		            |          | 2 : masked		  | the map has been masked				| |
|               | width		       | integer	 | 	  	| the width of the unwarped map					| |
|               | created_at	   | integer	 | 		   | the date and time when the map was added to the system					| |
| total_pages		 |               | integer 	|		               | the total number of pages in the result set		|    |
| per_page		    |               | integer  |		               | the number of results per page		|    |
| total_entries	|               | integer 	|	               	|	thetotal number of results					|    |

###Geography-Based Map Search

Returns a paginated list of warped maps that either intersect or fall within a specified geographic area, which is specified by a bounding box.

**Parameters**

| Name          | Type	| Description   | 
| ------------- |-------------| -------| 
| bbox	         | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited |

**Format**
```
     y.min (lon min) ,x.min (lat min) ,y.max (lon max), x.max (lat max)
```

**Example**

```
    -75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122
```

**Other Parameters** 

| Name          | Description	| Notes  |
| ------------- |-------------| -------|
| intersect	| uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter | preferred; orders results by proximity to the bbox extent |
| within	| uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter |      |

Format the query in JSON. 

**Request Examples**

[http://mapwarper.net/maps/geosearch?bbox=-74.4295114013431,39.71182637980763,-73.22376188967249,41.07147471270077&format=json&page=1&operation=intersect](http://mapwarper.net/maps/geosearch?bbox=-74.4295114013431,39.71182637980763,-73.22376188967249,41.07147471270077&format=json&page=1&operation=intersect)

**Response**

The response will be in the following format.
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

**Response Elements**

| Name        	 |               | Type	   | Value		         | Description					| Notes |
| ------------- |-------------	 | -----		 |-----------						| --------------  | ----  |
| stat		        |               | string 	|		               | the status of the request		|    |
| current_page		|               | integer |		               | indicates on which page of the search results the map appears		|    |
| items		       |               | an array of key pairs with information about the map 	|		|									| |
|               | updated_at	   | string	  | describes when the map was last updated		| e.g., "5 days ago."	|
|               | title		       | string 	 |		|		the title of the map							| |
|               | id		          | integer 	|		|		the unique identifier for the map						| |
|               | description	  | string	  |		|		the description of the map							| |
|               | height	       | integer 	| 	|  the height of an unwarped map				| |
|               | nypl_digital_id	| integer |	|  the NYPL digital ID, which is used for thumbnail images and links to thelibrary metadata		| |
|               | width		       | integer	 | 	  	| the width of the unwarped map					| |
|               | bbox		        | a comma-separated string of latitude and longitude coordinates	 | 	  	| a rectangle delineating the map's geographic footprint					| |
|               | updated_at	   | string	  | describes when the map was last updated		| e.g., "5 days ago."	|
| total_pages		 |               | integer 	|		               | the total number of pages in the result set		|    |
| per_page		    |               | integer  |		               | the number of results per page		|    |
| total_entries	|               | integer 	|	               	|	thetotal number of results					|    |

###Get a Map

| Method        | Definition    |
| ------------- | ------------- |
| GET           | http://mapwarper.net/maps/8461.json or     | 
|               | http://mapwarper.net/maps/8461?format=json |

Returns a map by ID.

**Parameters**

| Name        	 | Type		       | Description					| Required    | Notes |
| ------------- |-------------	| --------------- |-----------		| ----- |
| id  		        | integer 	    | the unique identifier for a map    | required		|    |
| format  		    | string 	     | can be used to request json output, rather than HTML or XML    | optional		| default is HTML   |

**Response**

The response will be be in the following format.
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

###Response Elements

| Name        	 | Type		       | Value		| Description					                  | Notes |
| ------------- |-------------	|-----		 | -----------------------------					| ----- |
| stat		        | string 	     |		      | the status of the request		       |       |
| items		       | an array of key pairs with information about the map 	||		|       |
| status	       | integer	     | 	      | the status of the map             |       |
| 	             | 	            | 0 : unloaded	| the map has not been loaded					    |
| 		            |		            | 1 : loading 	| the master image is being requested from the NYPL repository	| |
| 		            | 		           | 2 : available	| the map has been copied, and is ready to be warped	|   |
| 		            | 		           | 3 : warping	| the map is undergoing the warping process			|  |
| 		            | 		           | 4 : warped	| the map has been warped					  |       |
| 		            | 		           | 5 : published	| this status is set when the map should no longer be edited | not currently used |
| map_type	     | integer 	    | 0 : index	 | indicates a map index or overview map		| |
| 		| 		                       | 1 : is_map	| 										                     |  default |
| 		| 		                       | 2 : not_map	| indicates non-map content, such as a plate depicting sea monsters		|  |
| updated_at	   | string	      | describes when the image was last updated		 | e.g., "5 days ago."	|
| title		       | string 	     |		|	title of the map								                 |                     |
| id		          | integer 	    |		|	a unique identifier for the map						    |                     |
| description	  | string	      |		|	the description of the map								       |                     |
| height	       | integer 	    | 	| the height of the unrectified map				    |                     |
| nypl_digital_id	| integer    | 	| the NYPL digital id, which is used for thumbnail images and links to the library metadata		|  |
| catnyp_id	    | integer	     | 	| the NYPL digital catalog that is used to link to the library record 			|  |
| mask_status	  | integer	     |  | the status of the mask	                                  |   |
| 		            | 		           | 0 : unmasked		| 	the map has not been masked			             |   |
| 		            | 		           | 1 : masking		 | 	the map is undergoing the masking process		|   |
| 		            | 		           | 2 : masked		  | 	the map has been masked			                 |   |
| width		| integer	            | 		| the width of the unwarped map					                      |   |
| created_at	| integer	        | 		| the date and time when the map was added to the system		|   |

If a map is not found, the following HTTP response will be returned.

| Status        | Response |
| ------------- |----------| 
| 404	(not found)| ```{"items":[],"stat":"not found"}```    |

###Get Map Status

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/maps/{map_id}/status |

Returns a map's status. This request is used to poll a map while it is being transfered from the NYPL image server to the map server.

This request returns text. If a map has no status (i.e., has not been transferred yet), this request will return the status "loading."

While the request usually takes a few seconds, it could take several. Sometimes, the request does not succeed. 

**Request Example**

[http://mapwarper.net/maps/8991/status](http://mapwarper.net/maps/8991/status)

##Layers

A layer is a mosaic in which the component maps are stitched together and shown as one seamless map. Layers are often comprised of contiguous maps from the facing pages of a scanned book. For examples of layers, see the [Plan of the town of Paramaribo, capital of Surinam](http://maps.nypl.org/warper/layers/1450) or the map of New York City and Vicinity at [http://maps.nypl.org/warper/layers/1404](http://maps.nypl.org/warper/layers/1404).

###Query/List Layers

**Parameters**

| Name      	    |                  | Type     | Description |  Required | Notes |
| -----          | ---------------  | -------- | ----------- |  -------- | ----- |
| title      		  |              	   | string   | title of the map  | optional | default |
| description		  |                  | string   | description of the map              | optional |       |
| catnyp 		      |                  | integer  | NYPL digital catalog ID used to link to library record  | optional | |
| sort_key	             	           ||         | field on which the sort should be based                | optional |   |
| 		             | title            | string   | the title of the map	             | optional            | |
| 		             | depicts_year     |          | the year that the map depicts	| optional            | |
| 		             | updated_at       |          | when the map was last updated	| optional            | |
| 		             | mapscans_count   | integer  | how many maps a layer has, as opposed to title pages, plates, and other non-map content | a map is a resource that has “map_type” set to “is_map”; optional    | |
|		              | percent	         | integer  | the percentage of the total number of component maps that have been warped          | optional            | |
| sort_order	                       || string  | the order in which the results should appear    | optional            | |
|                | asc 	             | string  | ascending order               | optional            | |
|		              | desc	             | string  | descending order              | optional            | |
| format	        |     	             | string  | can be used to request json output, rather than HTML or XML  | optional            | default is HTML |
| page		         | 		                | integer | page number of search results	| optional            | |

**Query**        

Enter text for the search query, based on the field chosen. The query text is case insensitive.

      This is a simple exact string text search, i.e. a search for "city New York" retrieves no results, but a search for "city of New York" retrieves 22.

**Request Example**

[http://mapwarper.net/layers?field=name&amp;query=New+York&amp;format=json](http://mapwarper.net/layers?field=name&query=New+York&format=json)

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

###Get a Map's Layers

Returns a list of layers that include a given map.

**Parameters**

| Name      	    |             | Type  | Description  |  Required | Notes  |
| -------------  | ----------- | ----- | ------------ |  -------- | ------ |
| map_id     		  |             |integer    | the unique identifier for a map   | required | |
| name           |             | string    | the title of the map | optional  | default |
| sort_key	             	      ||          | the field on which the sort should be based  | optional | |
| 		              | title      | string    | the title of the map	             | optional        | |
| 		              | updated_at |           | when the map was last updated	| optional            | |
| sort_order	                  ||  string  | the order in which the items returned should appear | optional   | |
| format	         |     	      | string    | can be used to request “json” output, rather than HTML or XML   | optional | default is HTML |

**Request Example:** 

[http://mapwarper.net/layers?map_id=10090&field=name&sort_key=mapscans_count&sort_order=asc&query=New&format=json](http://mapwarper.net/layers?map_id=10090&field=name&sort_key=mapscans_count&sort_order=asc&query=New&format=json)

Alternatively, the URL can be constructed from the point of view of a map:

[http://mapwarper.net/maps/10090/layers.json](http://mapwarper.net/maps/10090/layers.json)

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

If not found, the following response will be returned.

| Status        | Response |
| ------------- | -------- | 
| 404	(not found)| ```{"items":[],"stat":"not found"}```    |

###Get Layer:

Returns a single layer.

**Request Examples**

[http://mapwarper.net/layers/760.json](http://mapwarper.net/layers/760.json)

or [http://mapwarper.net/layers/760?format=json](http://mapwarper.net/layers/760?format=json)

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

If not found with format=json, the following response will be returned.

| Status          | Response   |
| -------------   | ---------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

**Parameters**

| Element            | Type        |  Description	| Notes       |
| -------------      | ----------- |  ----------- | ----------- |
| bbox	| comma-separated string of latitude and longitude coordinates  | a bounding box, based on the extents of the tileindex shapefile that makes up the layer with maps |      |
| mapscans_count	    | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable; optional     |
| rectified_mapscans_count	      | integer   | how many maps in the layer are warped	|     |
| percent	           | integer   | the percentage of warped maps out of the total number of maps		|     | 
| depicts_year	      | year      | the year the layer depicts		|     |
| is_visible	        | boolean		 | when set to false, usually indicates a meta layer or collection of atlases | these meta-layers will not have WMSs |

###Get a Layer's Maps

Returns a paginated list of the maps that comprise a given layer.

**Request Examples**
 
[http://mapwarper.net/layers/maps/890?format=json&amp;show_warped=0](http://mapwarper.net/layers/maps/890?format=json&amp;show_warped=0) or

[http://mapwarper.net/layers/890/maps?format=json&show_warped=1](http://mapwarper.net/layers/890/maps?format=json&show_warped=1)

| Name          | Description | Required  | Notes     |
| ------------- | ----------  | --------  | --------  |
| layer_id      | the unique identifier for a layer   |  required         |       |
| format        | can be used to request json output, rather than HTML or XML     |    optional       |  default is HTML     |
| show_warped |  specifies whether to limit search to warped maps    | optional | default is "1", which limits to warped maps; "0" returns all maps |

**Response:**

The response will be in the following format.

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

###Map & Layer Web Map Services

The following Web map services (WMS) are available.

####Map WMS
[http://mapwarper.net/maps/wms/8561](http://mapwarper.net/maps/wms/8561)

####Layer WMS
[http://mapwarper.net/layers/wms/931](http://mapwarper.net/layers/wms/931)

####Map & Layer KML

**Map KML**

[http://mapwarper.net/maps/8561.kml](http://mapwarper.net/maps/8561.kml)

**Layer KML**

[http://mapwarper.net/layers/931.kml](http://mapwarper.net/layers/931.kml)

------------------------------

##Ground Control Points

Ground control points are the user-selected locations used to warp an image.

###Get a Map's Ground Control Points

| Method        | Definition    |
| ------------- | ------------- |
| GET           |     | 
|               |     |

Returns a list of the ground control points used to warp a map, as well as their calculated errors.

**Request Examples**

[http://mapwarper.net/maps/8561/gcps.json](http://mapwarper.net/maps/8561/gcps.json)

or [http://mapwarper.net/maps/8561/gcps?format=json](http://mapwarper.net/maps/8561/gcps?format=json)

**Response**

The response will be a list of ground control points in the following format.

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

If the map is not found, with format=json, the following response will be returned.

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

**Response Elements**

| Name          |             | Description | Notes   |
| ------------- | ---------   | ---------   | ------  |
| status        |             | the status of the request   | ```{ "stat": "ok" }``` |
| items		                     || an array of key pairs with information about the control points 	|		|									|
|               | lon           | the longitude of the control point                    |  |
|               | updated_at    | the date and time that the control points were last updated  |  |
|               | x             | the x coordinate that corresponds to "lon"   |  |
|               | y             | the y coordinate that corresponds to "lat"   |  |
|               | mapscan_id    | the unique identifier for the map            |  |
|               | id            | the ground control point’s ID                |  |
|               | error         | the calculated error, or distortion, for that control point   |  |
|               | lat           | the latitude of the control point   |  |
|               | created_at    | the date and time when the control point was created   |  |

With the following calls, if the GCP is not found with format=json, the following response will be returned.

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

###Get a Single Ground Control Point

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/gcps/{gcp_id}?format=|json |

Returns a specified ground control point by ID.

**Example**

[http://mapwarper.net/gcps/9579?format=json](http://mapwarper.net/gcps/{gcp_id}?format=|json)

**Response:**

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

**Response Elements**

| Name          |             | Description | Notes   |
| ------------- | ---------   | ---------   | ------  |
| status        |             | the status of the request   | ```{ "stat": "ok" }``` |
| items		                     || an array of key pairs with information about the control points 	|		|									|
|               | lon           | the longitude of the control point                    |  |
|               | updated_at    | the date and time that the control points were last updated  |  |
|               | x             | the x coordinate that corresponds to "lon"   |  |
|               | y             | the y coordinate that corresponds to "lat"   |  |
|               | mapscan_id    | the unique identifier for the map            |  |
|               | id            | the unique identifier for the GCP            |  |
|               | error         | the calculated error, or distortion, for that control point   |  |
|               | lat           | the latitude of the control point   |  |
|               | created_at    | the date and time when the control point was created    |  |

###Add Ground Control Points

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  http://mapwarper.net/gcps/add/{map_id} |

Adds the ground control points on which a warp will be based. Requires authentication.

**Parameters**

| Name          | Description | Required  | Notes |
| ------------- | ---------   | ------    | ----  |                                            
| map_id        | the map to which the new ground control point will be applied   | required    |             |
| lat           | the latitude of the control point to warp to                         | optional | default is 0   |
| lon           | the longitude of the control point to warp to                        | optional | default is 0   |
| x             | the x coordinate on the unwarped image that corresponds to "lon"     | optional | default is 0   |
| y             | the y coordinate on the unwarped image that corresponds to "lon"     | optional | default is 0   | 
| format        | can be used to request json output, rather than HTML or XML          | optional | default is HTML  |

**Request Example**

[http://mapwarper.net/gcps/add/7449](http://mapwarper.net/gcps/add/7449)

**cURL Example**

```
curl -X POST -d "x=1.1&y=2.3&format=json" -u name@example.com:password http://mapwarper.net/gcps/add/7449
```

**Response**

The response will be in the following format.

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

**Response Elements**

| Name          |             | Description | Notes   |
| ------------- | ---------   | ---------   | ------  |
| status        |             | the status of the request   | e.g., ```{ "stat": "ok" }``` |
| items		                     || an array of key pairs with information about the control points 	|		|									|
|               | lon           | the longitude of the control point                    |  |
|               | updated_at    | the date and time that the control points were last updated  |  |
|               | x             | the x coordinate that corresponds to "lon"   |  |
|               | y             | the y coordinate that corresponds to "lat"   |  |
|               | mapscan_id    | the unique identifier for the map            |  |
|               | id            | the unique identifier for the GCP            |  |
|               | error         | the calculated error, or distortion, for that control point   |  |
|               | lat           | the latitude of the control point   |  |
|               | created_at    | the date and time when the control point was created   |  |

An error will return the following message.

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

###Update All Fields of a GCP

| Method       | Definition | 
| ------------ | -------    | 
| PUT          |  http://mapwarper.net/gcps/update/{gcp_id} |

Updates all of the fields for a given GCP.

**Parameters**

| Name          | Description | Required  | 
| ------------- | ---------   | --------- | 
| gcp_id        |  unique identifier of the ground control point  |  required |

**Example**

[http://mapwarper.net/gcps/update/14803](http://mapwarper.net/gcps/update/14803)

**Example using cURL and HTTP BASIC**

```
curl -X PUT -d "lat=54.33&lon=-1.467&x=3666.335&y=2000.12&format=json" -u user@example.com:password http://mapwarper.net/gcps/update/14803
```

| Name          | Description | Required  | Notes |
| ------------- | ---------   | ------    | ----  |                                            |
| gcp_id        | the unique identifier of the ground control point            | required  |       |
| lat           | the latitude of the control point to warp to   | optional  | default is 0 |
| lon           | the longitude of the control point to warp to   | optional | default is 0 |
| x    | the x coordinate on the unwarped image that corresponds to "lon"    | optional | default is 0 |
| y    | the y coordinate on the unwarped image that corresponds to "lon"    | optional | default is 0 | 
| format        | can be used to request json output, rather than HTML or XML  |  optional         | default is HTML    |

**Response**
An error will appear in the following format.

```
{{{
{"items":[],"errors":[["lat","is not a number"]],"stat":"fail","message":"Could not update GCP"}
}}}
```

###Update One Field of a GCP

| Method        | Definition | 
| ------------- | ---------  | 
| PUT           |  http://mapwarper.net/gcps/update_field/{gcp_id} |

Updates a single field for a GCP. Requires authentication.

**Parameters**

| Name          | Description | Required  | Notes |
| ------------- | ---------   | ------    | ----  | 
| ??? field_id  ???    |    |  required |   |                                        |
| lat           | the latitude of the control point to warp to   | optional  | default is 0 |
| lon           | the longitude of the control point to warp to   | optional | default is 0 |
| x    | the x coordinate on the unwarped image that corresponds to "lon"    | optional | default is 0 |
| y    | the y coordinate on the unwarped image that corresponds to "lon"    | optional | default is 0 | 
| value         | value to change                  |           |       |
| format        | can be used to request json output, rather than HTML or XML  |  optional         | default is HTML    |

**Example**

[http://mapwarper.net/gcps/update_field/14803]

**Response**

An error will appear in the following format.

```
{{{
{"items":[],"errors":[["lat","is not a number"]],"stat":"fail","message":"Could not update GCP"}
}}}
```

###Delete GCP

| Method        | Definition | 
| ------------- | ---------  | 
| DELETE        |  http://mapwarper.net/gcps/destroy/{gcp_id} |

Deletes a ground control point. Requires authentication.

**Parameters**

| Name        | Description | Required  | 
| ----------- | --------- | ---------   | 
| gcp_id      |  the unique identifier for a ground control point  |  required |

Example: 

[http://mapwarper.net/gcps/destroy/14805](http://mapwarper.net/gcps/destroy/14805)

**Response**

An error will appear in the following format.

```
{{{
{"items":[],"errors":[["field","message about field"]],"stat":"fail","message":"Could not delete GCP"}

}}}
```

##Masking

Uses GML to mask a portion of the map. This essentially crops the map. Masking is used to delete the borders around the map images to make a seamless layer of contiguous maps. Requires authentication.

###Get Mask

| Method        | Definition | 
| ------------- | -------    | 
| GET           |  http://mapwarper.net/shared/masks/{map_id}.gml.ol |

Gets a GML file containing polygons of the clipping mask.

**Examples**

http://mapwarper.net/shared/masks/7449.gml.ol

http://mapwarper.net/shared/masks/7449.gml.ol?1274110931 (with a timestamp to assist in browser cache busting)

**Response Example**

```
{{{
<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1474.9689999999998,5425.602 3365.091,5357.612 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4493.725,1917.318 4072.187,1645.358 3079.533,1441.388 2467.623,1427.79 2304.447,1264.614 1529.3609999999999,1332.6039999999998 1542.9589999999998,1862.926 2005.291,2202.876 1624.547,2542.826 </nowiki><nowiki>1651.743,3195.53 1665.341,3698.656 1692.5369999999998,3997.812 2005.291,4201.782 2005.291,4419.35 1570.155,5140.044 1474.9689999999998,5425.602</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_201"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1447.773,4854.486 1828.5169999999998,4582.526 1950.899,4242.576 1774.125,4065.802 1583.753,3902.626 1610.949,3345.108 1597.3509999999999,2923.57 1447.773,2638.0119999999997 1379.783,2787.59 1338.989,4854.486 1447.773,4854.486</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>
}}}
```

###Save Mask

| Method        | Definition | 
| ------------- | -------    | 
| POST          |  http://mapwarper.net/maps/{map_id}/save_mask |

Saves a mask. Returns a text string with a message indicating success or failure. Requires authentication.

**Request Example**

[http://mapwarper.net/maps/7449/save_mask]9http://mapwarper.net/maps/7449/save_mask)

**cURL Example**

```
{{{
curl -X POST -d "format=json" -d 'output=<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>' -u user@example.com:pass  http://mapwarper.net/maps/7449/save_mask
}}}
```

**Parameters**

| Name          | Value        | Type        | Required  | 
| ------------- | ---------    | ----------  | --------- |
| format        |  jsonoutput  |  GML string | optional  | 

Example:

```
{{{
<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>
}}}
```

**Response**

A successful call will return the following message. 

```
{"message":"Map clipping mask saved (gml)"}
```

###Delete Mask

| Method        | Definition | 
| ------------- | -------    | 
| POST          |  http://mapwarper.net/maps/{map_id}/delete_mask |

Deletes a mask. Requires authentication.

**Parameters** 

| Name          | Description | Required  | 
| ------------- | ---------   | ------    |
| map_id        |  the unique identifier for a map                                    |  required         |
| format        |  can be used to request json output, rather than HTML or XML        |  optional         | 

**Response**

| Status        | Response |
| ------------- | -------- | 
| 200	(OK)| ```{"stat":"ok","message":"mask deleted"}```    |
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |


###Mask Map

| Method        | Definition | 
| ------------- | -------    | 
| POST          |  http://mapwarper.net/maps/{map_id}/mask_map |

Applies the clipping mask to a map, but does not warp it. A clipping mask should be saved before calling this. Requires authentication.

**Response**

| Status        | Response | Notes |
| ------------- | -------  | ----  | 
| 200	(OK) | ```{"stat":"ok","message":"Map cropped"}```    | success                |
| 404	(not found) | ```{"items":[],"stat":"not found"}```   | no clipping mask found |

###Save, Mask, and Warp Map

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  http://mapwarper.net/maps/{map_id}/save_mask_and_warp |

Rolls the calls into one. Saves the mask, applies the mask to the map, and warps the map using the mask. Requires authentication.

**Parameters**

| Name        | Description | 
| ----------- | -------     | 
| map_id      | the unique identifier for a map |

**Response**

The output will be a GML string containing polygon(s) to mask over (see Save Mask).

| Status        | Response | Notes |
| ------------- | -------  | ----- |
| 200	(OK) | ```{"stat":"ok","message":"Map masked and rectified!"}```    | success |
| 200	(OK )| ```{"stat":"ok","message":"Map masked but it needs more control points to rectify"}```    | returned when a map has less than three control points |
| 404	(not found) | ```{"items":[],"stat":"not found"}```    | no clipping mask found |

###Warping

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  http://mapwarper.net/maps/{map_id}/rectify |

Warps or rectifies a map according to its saved GCPs and the parameters passed in. Requires authentication.

**Example:**

[http://mapwarper.net/maps/7449/rectify](http://mapwarper.net/maps/7449/rectify)

**Curl Example:**

```
curl -X POST -d "use_mask=false&format=json" -u email@example.com:password  http://mapwarper.net/maps/7449/rectify
```

**Parameters**

resample options  (optional - nearest neighbor is given as default)


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

**Response**

| Status          | Response | Notes |
| -------------   | -------  | ----- |
| 200	(OK)        | ```{"stat":"ok","message":"Map rectified."}```    | success  |
|                 | ```{"stat":"fail","message":"not enough GCPS to rectify"}```    | map doesn't have enough GCPS saved |
| 404	(not found) | ```{"items":[],"stat":"not found"}```    | map not found |
