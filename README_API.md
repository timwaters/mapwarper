#Wikmaps Warper API Documentation

> ** Note: This has Wikimaps specific implementation details, for interacting with Wikimedia Commons as an image repository, and so will differ with the standard mapwarper.net API. 

Welcome to the documentation for the Wikimaps Warper API! MapWarper is a free application that assigns the proper geographic coordinates to scanned maps in image formats. Users can upload images, then assign ground control points to match them up with a base map. Once MapWarper warps or stretches the image to match the corresponding extent of the base map, it can be aligned and displayed with other maps, and used for digital geographic analysis. You can access all of the functionality through the API. 

##Table of Contents

[Format](#format)
[Authentication](#authentication)  
[Search for Maps](#search-for-maps)   
[Get a Map](#get-a-map)  
[Get a Map's Status](#get-a-maps-status)   
[Layers](#layers)  
[Query or List Layers](#query-or-list-layers)  
[Get a Map's Layers](#get-a-maps-layers)  
[Get Layer](#get-layer)  
[Get a Layer's Maps](#get-a-layers-maps)  
[Map and Layer Web Map Services](#map-and-layer-web-map-services)  
[Ground Control Points](#ground-control-points)  
[Get a Map's Ground Control Points](#get-a-maps-ground-control-points)  
[Get a Single Ground Control Point](#get-a-single-ground-control-point)  
[Add Ground Control Points](#add-ground-control-points)  
[Update All Fields of a GCP](#update-all-fields-of-a-gcp)  
[Update One Field of a GCP](#update-one-field-of-a-gcp)  
[Delete a GCP](#delete-a-gcp)  
[Masking](#masking)  
[Get Mask](#get-mask)  
[Save Mask](#save-mask)  
[Delete Mask](#delete-mask)  
[Mask Map](#mask-map)  
[Save, Mask, and Warp Map](#save-mask-and-warp-map)  
[Warping](#warping)  

##Format

Where possible most output formats are in json-api format. Some creation and updating requests also require the json to be in this format. 

### JSON format

For more infomation about the JSON API format, please consult [http://jsonapi.org/](http://jsonapi.org/). 
Things to watch out for (compared to the previous warper API) the JSON API has `data` as a root array, and the data for each feature are in an `attributes` array. The format also allows the system to include `relationships` (for example, including the layers with each map) and also shows `links` to various resources and contains pagination `meta` information.

The GeoJSON is different in structure and also in that it encodes the geometry of features in GeoJSON format. It does not include relations or links or pagination information. For more information about the GeoJSON format see the GeoJSON site. [http://geojson.org/](http://geojson.org/)

##Authentication

Some calls do not require authentication. Some do, and some require the user to have the correct authorization.

Authentication for the MapWarper API is via an authentication token passed in a header. This can be obtained via Oauth via the postMessage browser API, or via email and login.

Alternatively the API can work via cookie also.

**Curl Examples for Email and password authentication and authentication token**

TODO - Implement & Document

**Curl Examples for Email and password authentication and cookies**
```
curl -X POST http://localhost:3000/u/sign_in.json -H "Content-Type: application/json" -d '{"user":{"email":"tim@example.com","password":"password"}}' -c cookie
```
if successful, returns logged in user as jsonapi with roles relationships (see User and Roles section)
```
{"data":{"id":"2","type":"users","attributes":{"login":"tim","created-at":"2010-08-26T15:37:34.619Z","enabled":true,"provider":null,"email":"tim@example.com"},"relationships":{"roles":{"data":[{"id":"1","type":"roles"},{"id":"2","type":"roles"},{"id":"3","type":"roles"},{"id":"4","type":"roles"}]}},"links":{"self":"http://localhost:3000/api/v1/users/2"}}}
```
if unauthorized returns a 401 status with
```
{"error":"Invalid email or password."}
```
Example using the cookie:
```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET http://localhost:3000/api/v1/users/2.json -b cookie

```


##Search for Maps


| Method        | Definition |
| ------------- | ---------  |
| GET           | http://mapwarper.net/api/v1/maps.json?query=london | 

Returns a list of maps that meet search criteria (where the title or description contains "london")

**Parameters**

| Name      	    |   values   | Type  | Description  |  Required | Notes  |
| -----           | -----       | ----- | ---------    |  -----    | ------ |
| query           |             |string | search query | optional  |        |
| field           |             |string | specified field to be searched     | optional  | default is title  |
|       		      | title      	|string  | the title of the map   | optional | default |
|       		      | description | string | the description of the map | optional |       |
|       		      | publisher   | string | the publisher | optional |       |
|       		      | author      | string | the author of the map | optional |       |
|       		      | status      | string | the status  | optional |       |
| sort_key	      |            |         | the field that should be used to sort the results  | optional | defaul is updated_at  |
| 		            | title      | string    | the title of the map	             | optional            | |
| 		            | updated_at | string   | when the map was last updated	| optional            |  default |
| 		            | created_at | string   | when the map was last created	| optional            | |
|		              | status	   | string   | the status of the map	            | optional            | ordered by integer (see below) |
| sort_order	    |            |  string  | the order in which the results should appear | optional            | default is desc|
|                 | asc 	     |           | ascending order               | optional            | |
|		              | desc	     |           | descending order              | optional            | default |
| show_warped	    | 		       | integer   | limits to maps that have already been warped   | optional |    | 
|           	    | 1         | integer   | limits to maps that have already been warped   | optional  |    | 
|           	    | 0         | integer   | gets all maps, warped and unwarped             | optional  |  default | 
| format	        |     	     | string    | specifies output format       | optional      | can also be passed in as extension, eg. maps.json  |
|                 | json       | string    | JSON format for maps   | optional            | default | 
|                 | geojson    | string    | GeoJSON format for maps | optional           |       |
| page		        | 		        | integer   | the page number; use to get the next or previous page of search results | optional | |
| per_page        |             | integer   | number of results per page | optional |default is 50 |
| bbox	         | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited | optional |
| operation     |           | string       | specifies how to apply the bounding box  | optional  | default is intersect |
|               | intersect | string       |uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter  | optional | preferred; orders results by proximity to the bbox extent; default |
|               | within    | string	      | uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter  | optional      |  |
 

Notes: Enter optional text for the query, based on the search field chosen. The query text is case insensitive. This is a simple exact string text search. For example, a search for "city New York" returns no results, but a search for "city of New York" returns 22. bbox format is y.min(lon min),x.min(lat min),y.max(lon max), x.max(lat max)


**Example json format**
```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET 'http://localhost:3000/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1'
```
[http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1)

Example searching within a bounding box
```
http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&bbox=-75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122
```

**Response**

JSON API Format
```
{
	"data": [{
		"id": "260",
		"type": "maps",
		"attributes": {
			"title": "File:Tartu turismiskeem.png",
			"description": "From: http://commons.wikimedia.beta.wmflabs.org/wiki/File:Tartu_turismiskeem.png ",
			"width": 800,
			"height": 595,
			"status": "warped",
			"mask-status": "unmasked",
			"created-at": "2016-02-07T17:52:19.479Z",
			"updated-at": "2016-04-10T17:00:36.586Z",
			"bbox": "26.66587052714201,58.33686848133336,26.806590271771057,58.407077366797424",
			"map-type": "is_map",
			"source-uri": "http://commons.wikimedia.beta.wmflabs.org/wiki/File:Tartu_turismiskeem.png",
			"unique-id": "Tartu_turismiskeem.png",
			"page-id": "52021",
			"date-depicted": "",
			"image-url": "http://upload.beta.wmflabs.org/wikipedia/commons/4/44/Tartu_turismiskeem.png",
			"thumb-url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/4/44/Tartu_turismiskeem.png/100px-Tartu_turismiskeem.png"
		},
		"relationships": {
			"layers": {
				"data": [{
					"id": "43",
					"type": "layers"
				}, {
					"id": "44",
					"type": "layers"
				}]
			},
			"added-by": {
				"data": {
					"id": "2",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://localhost:3000/api/v1/maps/260",
			"gcps-csv": "http://localhost:3000/maps/260/gcps.csv",
			"mask": "http://localhost:3000/mapimages/260.gml.ol",
			"geotiff": "http://localhost:3000/maps/260/export.tif",
			"png": "http://localhost:3000/maps/260/export.png",
			"aux-xml": "http://localhost:3000/maps/260/export.aux_xml",
			"kml": "http://localhost:3000/maps/260.kml",
			"tiles": "http://warper.wmflabs.org/maps/tile/260/{z}/{x}/{y}.png",
			"wms": "http://localhost:3000/maps/wms/260?request=GetCapabilities\u0026service=WMS\u0026version=1.1.1"
		}
	}],
	"included": [{
		"id": "43",
		"type": "layers",
		"attributes": {
			"name": "Category:Maps Of Tartu",
			"description": null
		},
		"links": {
			"self": "http://localhost:3000/api/v1/layers/43"
		}
	}, {
		"id": "44",
		"type": "layers",
		"attributes": {
			"name": "Category:Tartu Maps",
			"description": null
		},
		"links": {
			"self": "http://localhost:3000/api/v1/layers/44"
		}
	}],
	"links": {
      "self":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=1\u0026page%5Bsize%5D=2\u0026per_page=2",
      "next":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=2\u0026page%5Bsize%5D=2\u0026per_page=2",
      "last":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=3\u0026page%5Bsize%5D=2\u0026per_page=2"
  },
	"meta": {
		"total-entries": 5,
		"total-pages": 2
	}
}
```


**Response Elements**

*** Data ***

An array of maps, each having an attributes object and, id and type and links

| Name          |    Value	   | Description					| Notes |
| ------------- |		-----------	| --------------  | ----  |
| id            |               | The id for the map  |       |
| type          |    maps       | the type of resource |      |
| links         |               | links to the resource, and export links|   | 
| attributes    |               | Attributes of the map | see separate table for more detail |
| relationships | layers, added-by | the layers that the map belongs to and the user that uploaded it | (see included)|
| included      |               | Details about the layers  || 

*** Map Links ***

| Value | Description |
| ------| -------     |
| gcps-csv| CSV for the control points |
| mask |  the GML clipping mask |
| geotiff | The export GeoTiff url |
| png |The export PNG url |
| aux-xml | The export PNG XML url |
| kml | The export KML url |
| tiles | The Tiles template |
| wms | The WMS getCapabilities endpoint |  


*** Links ***

The top level links holds pagination links

```
"links": {
    "self":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=1\u0026page%5Bsize%5D=2\u0026per_page=2",
    "next":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=2\u0026page%5Bsize%5D=2\u0026per_page=2",
    "last":"http://wikimaps.mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=3\u0026page%5Bsize%5D=2\u0026per_page=2"
},
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |

*** Meta ***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total-entries": 50,
  "total-pages": 2
}
```
indicates that 50 results have been found over 2 pages.

| Value | Description |
| ------| -------     |
| total-entries | the total number of maps found for this request |
| total-pages |  the total number of pages found |

 
*** Attributes ***

| Name        	 | Type	   | Value		    | Description					| Notes |
| -------------  | -----	|-----------		| --------------  | ----  |
| status	       |  string  |                   |  the status of the map  |   |
| 		           |          | unloaded	  | the map has not been loaded					       | |
| 		           |          |  loading 	  | the master image is being requested from the NYPL repository	 |    |
| 		           |          |  available	| the map has been copied and is ready to be warped	|  |
| 		           |          |  warping	  | the map is undergoing the warping process			|  |
| 		           |          |  warped	    | the map has been warped					|  |
| 		           |          |  published	| this status is set when the map should no longer be edited |  |
| map-type	     | string 	|             | indicates whether the image is of a map or another type of content	| |
|         	     |         	| index	      | indicates a map index or overview map							| |
| 		           |          | is_map	    | indicates a map 										| default |
| 	 	           |          | not_map	    | indicates non-map content, such as a plate depicting sea monsters		| |
| updated-at	   | datetime  | 	        	| when the map was last updated	| |
| created-at	   | datetime  | 	        	| when the map was first created	| |
| title		       | string 	 |       		  |	the title of the map							| |
| description	   | string	  |	        	  |		the description of the map							| |
| height	        | integer 	|          	|  the height of an unwarped map				| |
| width	          | integer 	|        	  |  the width of an unwarped map				| |
| mask-status	    | string	 |            | the status of the mask		| |
| 		            |          |  unmasked	| the map has not been masked				| |
| 		            |          |  masking		| the map is undergoing the masking process				| |
| 		            |          |  masked		| the map has been masked				| |
| bbox	          | comma-separated string of lat & lon coords |    | a rectangle delineating the geographic area to which the search should be limited | |
| source-uri	 | string 	|              	|  the URI to the source map page			| e.g. the wiki page |
| unique-id	    | string 	|             	|  the image filename taken from the source image |  |
| page-id	      | integer |             	|  The Wiki PAGEID for the source				| |
| date-depicted	| string 	|             	|  string representation of the date that the map depicts	| |
| image-url	    | string 	|              	|  URL to the original full size image| |
| thumb-url	    | string 	|             	| URL to the thumbnail 	| 100px dimension |



**Example geojson format**

```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET 'http://localhost:3000/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1&format=geojson'
```
[http://mapwarper.net/api/v1/maps.geojson?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps.geojson?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1)

*** Response ***

```
[{
	"id": 260,
	"type": "Feature",
	"properties": {
		"title": "File:Tartu turismiskeem.png",
		"description": "From: http://commons.wikimedia.beta.wmflabs.org/wiki/File:Tartu_turismiskeem.png ",
		"width": 800,
		"height": 595,
		"status": "warped",
		"created_at": "2016-02-07T17:52:19.479Z",
		"bbox": "26.66587052714201,58.33686848133336,26.806590271771057,58.407077366797424",
		"thumb_url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/4/44/Tartu_turismiskeem.png/100px-Tartu_turismiskeem.png",
		"page_id": "52021"
	},
	"geometry": {
		"type": "Polygon",
		"coordinates": "[[[26.66587052714201, 58.33686848133336], [26.806590271771057, 58.33686848133336], [26.806590271771057, 58.407077366797424], [26.66587052714201, 58.407077366797424], [26.66587052714201, 58.33686848133336]]]"
	}
}]
```


###Get a Map

| Method        | Definition    |
| ------------- | ------------- |
| GET           | http://mapwarper.net/api/v1/maps/{:id}.{:format} or     | 
|               | http://mapwarper.net/api/v1/maps/{:id}?format={:format} |

Returns a map by ID.

**Parameters**

| Name          |              | Type         | Description					                | Required    | Notes |
| ------------- |------------- | ------------ |----------------------------------		| ----------- | ----- |
| id  		      |              | integer 	     | the unique identifier for a map    | required		  |       |
| format  		  |              | string 	     | specifies output format            | optional		  | default JSON  |
|               | json / geojson|             | use to specify JSON output formar   | optional |  |

**Response**

JSON-API
The response will be be in the following format.
```
{
	"data": {
		"id": "2",
		"type": "maps",
		"attributes": {
			"title": "File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"description": "From: http://commons.wikimedia.beta.wmflabs.org/wiki/File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"width": 595,
			"height": 760,
			"status": "warped",
			"mask-status": "unmasked",
			"created-at": "2015-10-20T17:17:58.300Z",
			"updated-at": "2016-06-08T10:55:13.660Z",
			"bbox": "-7.706061311682345,49.02738371829112,3.420945210059412,56.46163780182066",
			"map-type": "is_map",
			"source-uri": "http://commons.wikimedia.beta.wmflabs.org/wiki/File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"unique-id": "Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"page-id": "51038",
			"date-depicted": "",
			"image-url": "http://upload.beta.wmflabs.org/wikipedia/commons/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"thumb-url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg/100px-Lawrence-h-slaughter-collection-of-english-maps-england.jpeg"
		},
		"relationships": {
			"layers": {
				"data": [{
					"id": "1",
					"type": "layers"
				}]
			},
			"added-by": {
				"data": {
					"id": "5",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://wikimaps.mapwarper.net/api/v1/maps/2",
			"gcps-csv": "http://wikimaps.mapwarper.net/maps/2/gcps.csv",
			"mask": "http://wikimaps.mapwarper.net/mapimages/2.gml.ol",
			"geotiff": "http://wikimaps.mapwarper.net/maps/2/export.tif",
			"png": "http://wikimaps.mapwarper.net/maps/2/export.png",
			"aux-xml": "http://wikimaps.mapwarper.net/maps/2/export.aux_xml",
			"kml": "http://wikimaps.mapwarper.net/maps/2.kml",
			"tiles": "http://warper.wmflabs.org/maps/tile/2/{z}/{x}/{y}.png",
			"wms": "http://wikimaps.mapwarper.net/maps/wms/2?request=GetCapabilities\u0026service=WMS\u0026version=1.1.1"
		}
	},
	"included": [{
		"id": "1",
		"type": "layers",
		"attributes": {
			"name": "Category:1681 maps",
			"description": null
		},
		"links": {
			"self": "http://wikimaps.mapwarper.net/api/v1/layers/1"
		}
	}]
}
```

GeoJSON Format
```
{
	"id": 2,
	"type": "Feature",
	"properties": {
		"title": "File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
		"description": "From: http://commons.wikimedia.beta.wmflabs.org/wiki/File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
		"width": 595,
		"height": 760,
		"status": "warped",
		"created_at": "2015-10-20T17:17:58.300Z",
		"bbox": "-7.706061311682345,49.02738371829112,3.420945210059412,56.46163780182066",
		"thumb_url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg/100px-Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
		"page_id": "51038"
	},
	"geometry": {
		"type": "Polygon",
		"coordinates": "[[[-7.706061311682345, 49.02738371829112], [3.420945210059412, 49.02738371829112], [3.420945210059412, 56.46163780182066], [-7.706061311682345, 56.46163780182066], [-7.706061311682345, 49.02738371829112]]]"
	}
}
```

**Response Elements**

See Maps section for description of fields etc

** Not Found Error **

If the map is not found, the request will return the following response.

| Status        | Response |
| ------------- |----------| 
| 404	(not found)| ```{"errors":[{"title":"Not found","detail":"Couldn't find Map with 'id'=2222"}]}```    |

###Get a Map's Status

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/api/v1/maps/{:id}/status |

Returns a map's status. This request is used to poll a maps status while it is being transfered from the wiki image server to the map server.

**Parameters**

| Name      	    |  Type      | Description  |  Required | 
| -------------  | ---------- | ------------ |  -------- | 
|   id     		  | integer    | the unique identifier for the map   | required |

**Request Example**

[http://mapwarper.net/api/v1/maps/8991/status](http://mapwarper.net/maps/api/v1/8991/status)

**Response**

This request returns text. If a map has no status (i.e., has not been transferred yet), this request will return the status "loading." While the request usually takes a few seconds, it could take several. 

**Response Elements**

| Name        	 | Type		   | Value		| Description					                  | Notes |
| ------------- |------------|-----		 | -----------------------------					| ----- |
| status	       | string	   | 	      | the status of the map             |       |
| 	             | 	         | unloaded	| the map has not been loaded					    |
| 		            |		       | loading 	| the master image is being requested from the NYPL repository	| |
| 		            | 		     | available| the map has been copied, and is ready to be warped	|   |
| 		            | 		     |  warping	| the map is undergoing the warping process			|  |
| 		            | 		     |  warped	| the map has been warped					  |       |
| 		            | 		     |  published	| this status is set when the map should no longer be edited | |

##Layers

A layer is a mosaic in which the component maps are stitched together and displayed as one seamless map. Layers are often comprised of contiguous maps from the facing pages of a scanned book. For examples of layers, see the [Plan of the town of Paramaribo, capital of Surinam](http://maps.nypl.org/warper/layers/1450) or the map of New York City and Vicinity at [http://maps.nypl.org/warper/layers/1404](http://maps.nypl.org/warper/layers/1404).

###Query or List Layers

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/layers?field=key1 |

**Parameters**

| Name      	    |                  | Type     | Description |  Required | Notes |
| -----          | ---------------  | -------- | ----------- |  -------- | ----- |
| title      		  |              	   | string   | the title of the layer  | optional | default |
| description		  |                  | string   | the description of the layer  | optional |       |
| sort_key	             	           ||         | the field that should be used to sort the results   | optional |   |
| 		             | title            | string   | the title of the layer	         | optional            | |
| 		             | depicts_year     |          | the year that the layer depicts	| optional            | |
| 		             | updated_at       | date, time, & time zone   | when the layer was last updated	| optional            | |
| 		             | mapscans_count   | integer  | how many maps a layer has, as opposed to title pages, plates, and other non-map content | optional |  a map is a resource that has the “map_type” attribute set to “is_map”   | |
|		              | percent	         | integer  | the percentage of the total number of component maps that have been warped          | optional            | |
| sort_order	                       || string  | the order in which the results should appear    | optional   | |
|                | asc 	             |         | ascending order               | optional            | |
|		              | desc	             |         | descending order              | optional            | |
| format	        |     	             | string  | specifies output format       | optional            | default is HTML |
|                | json              |         | use to specify JSON output, rather than HTML or XML | optional | |       
| page		         | 		                | integer | the search results page on which the layer appears	| optional            | |

**Query**        

Enter text for the query, based on the search field chosen. The query text is case insensitive.

      This is a simple exact string text search. For example, a search for "city New York" retrieves no results, while a search for "city of New York" retrieves 22.

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

**Response Elements**

| Name               |             | Type         |  Description	| Notes       |
| -------------      | ----------- |  ----------- | -----------  | ----------- |
| current_page	      |             | integer      | the search results page on which the layer appears  |      |
| items              |             | array        | an array of key pairs with information about the layer |  |
|                    | name        | string       | the title of the layer |  |
|                    | is_visible	 | boolean		 | when set to false, usually indicates a meta-layer or collection of atlases | these meta-layers will not have Web map services (WMS)   |
|                    | updated_at         | date, time, & time zone | when the layer was last updated |  |
|                    | mapscans_count	    | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable; optional     |
|                    | id                 | integer   | the unique identifier for the layer |  |
|                    | rectified_mapscans_count	      | integer   | how many maps in the layer are warped	|     |
|                    | depicts_year	      | year      | the year the layer depicts		|     |
|                    | bbox	              | a comma-separated string of latitude and longitude coordinates   | a rectangle delineating the geographic footprint of the layer 		|     | 
|                    | created_at         | date, time, & time zone | when the layer was created | |
| total_pages		      |                    | integer 	| the total number of pages in the result set		|    |
| per_page		         |                    | integer  |	the number of search results per page		|    |
| total_entries	     |                    | integer 	|	the total number of search results					|    |

###Get a Map's Layers

| Method       | Definition | 
| ------------ | ---------  | 
| GET          |  http://mapwarper.net/layers?map_id={:map_id} |

Returns a list of layers that include a given map.

**Parameters**

| Name      	    |             | Type  | Description  |  Required | Notes  |
| -------------  | ----------- | ----- | ------------ |  -------- | ------ |
| map_id     		  |             |integer    | the unique identifier for a map   | required | |
| name           |             | string    | the title of the map | optional  | default |
| sort_key	             	      ||          | the field that should be used to sort the results  | optional | |
| 		              | title      | string    | the title of the map | optional        | |
| 		              | updated_at | date, time, & time zone   | when the map was last updated	| optional            | |
| sort_order	                  ||  string  | the order in which the results should appear | optional   | |
|                 | asc 	      |           | ascending order               | optional            | |
|		               | desc	      |           | descending order              | optional            | |
| format	         |     	      | string    | specifies output format       | optional | default is HTML |
|                 | json       |           | use to specify JSON output, rather than HTML or XML | optional | |

**Request Example** 

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
     "depicts_year": null,
     "bbox": "-83.179076,39.640270,-69.331971,45.723733",
     "created_at": "2009/03/23 21:21:19 -0400"
   }
 ]
}
}}}
```

**Response Elements**

| Name               |             |  Type        |  Description	| Notes       |
| ----------------   | ----------- |  ----------- | -----------  | ---------   | 
| stat	              |             | string       | the HTTP response for the status of the request |    |
| items              |             | array        | an array of key pairs with information about the layer |  |
|                    | name        | string       | the title of the map |  |
|                    | is_visible	 | boolean		    | when set to false, usually indicates a meta-layer or collection of atlases | these meta-layers will not have WMS  |
|                    | updated_at  | date, time, & time zone   | when the map was last updated |  |
|                    | mapscans_count	    | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable; optional     |
|                    | id                 | integer   | the unique identifier for the layer |  |
|                    | rectified_mapscans_count	      | integer   | how many maps in the layer are warped	|     |
|                    | depicts_year	      | year      | the year the layer depicts		|     |
|                    | bbox	              | a comma-separated string of latitude and longitude coordinates   | a rectangle delineating the geographic footprint of the layer 		|     | 
|                    | created_at		       | date, time, & time zone 	|		when the layer was created in the system		|    |


If not found, the request will return the following response (when using "format=json").

| Status        | Response |
| ------------- | -------- | 
| 404	(not found)| ```{"items":[],"stat":"not found"}```    |



###Get Layer

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/layers/{:layer_id}.json or |
|              |  http://mapwarper.net/layers/{:layer_id}?format=json |

Returns a single layer.

**Parameters**

| Name          |             | Type      | Description | Required  | Notes     |
| ------------- | ----------  | --------  | ----------  | --------- | --------- |
| layer_id      |             | integer   | the unique identifier for the layer   |  required   |                 |
| format        |             | string    | specifies output format               |  optional   | default is HTML |
|               | json        |           | use to specify JSON output, rather than HTML or XML | optional |      |

**Request Examples**

[http://mapwarper.net/layers/760.json](http://mapwarper.net/layers/760.json) or

[http://mapwarper.net/layers/760?format=json](http://mapwarper.net/layers/760?format=json)

**Response**

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
     "depicts_year": "1671",
     "bbox": "-65.077269,32.107121,-64.553078,32.521725",
     "created_at": "2009/03/23 21:21:19 -0400"
   }
 ]
}
}}}
```

**Response Elements**

| Element            |             | Type        |  Description	| Notes      |
| -------------      | ----------- |  ---------- | ----------- | ----------  |
| stat	              |             | string      | the HTTP response for the status of the request  | |
| items              |             | array       | an array of key pairs with information about the layer |  |
|                    | name        | string      | the title of the layer |  |
|                    | is_visible  | boolean		   | when set to false, usually indicates a meta-layer or collection of atlases | these meta-layers will not have WMSs   |
|                    | updated_at         | date, time, & time zone  | when the layer was last updated |  |
|                    | mapscans_count	    | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable; optional     |
|                    | id                 | integer   | the unique identifier for the layer |  |
|                    | rectified_mapscans_count	      | integer   | how many maps in the layer are warped	|     |
|                    | depicts_year	      | year      | the year the layer depicts		|     |
|                    | bbox	              | a comma-separated string of latitude and longitude coordinates   | a rectangle delineating the geographic footprint of the layer 		|     | 
|                    | created_at		       | date, time, & time zone 	|		when the layer was created in the system		|    |

If not found, the request will return the following response (when using "format=jso"n).

| Status          | Response   |
| -------------   | ---------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

###Get a Layer's Maps

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  http://mapwarper.net/layers/maps/{:layer_id} or |
|              |  http://mapwarper.net/layers/{:layer_id}/maps |

Returns a paginated list of the maps that comprise a given layer.

**Parameters**

| Name          |             | Description | Required  | Notes     |
| ------------- | ----------  | --------    | --------  | -------   |
| layer_id      |             | the unique identifier for the layer   |  required  |                    |
| format        |             | specifies output format      |    optional       |  default is HTML     |
|               | json        | requests output in JSON format, rather than HTML or XML | optional | |
| show_warped   |             | specifies whether to limit search to warped maps        | optional | default is "1," which limits to warped maps; "0" returns all maps |

**Request Examples**
 
[http://mapwarper.net/layers/maps/890?format=json&show_warped=0](http://mapwarper.net/layers/maps/890?format=json&show_warped=0) or

[http://mapwarper.net/layers/890/maps?format=json&show_warped=1](http://mapwarper.net/layers/890/maps?format=json&show_warped=1)

**Response**

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

**Response Elements**

| Name               |               | Type         |  Value       | Description	| Notes     |
| -------------      | -----------   |  ----------- | -----------  | ----------- | --------  |
| stat	              |               | string       |              | the HTTP response for the status of the request  | |
| current_page       |               | integer      |              | the search results page on which the map appears | |
| items              |               | array        |              | an array of key pairs with information about the map | |
|                    | status	       |   integer    |              | the status of the map             | |
| 	                  |               |              | 0 : unloaded	| the map has not been loaded					  | |
| 		                 |	              |              | 1 : loading 	| the master image is being requested from the NYPL repository	| |
| 		                 |             	 |              | 2 : available | the map has been copied, and is ready to be warped	| |
| 		                 |               |              | 3 : warping	  | the map is undergoing the warping process			| |
| 		                 |               |              | 4 : warped	   | the map has been warped					  | |
| 		                 |               |              | 5 : published	| this status is set when the map should no longer be edited | not currently used | 
|                    | map_type	     | integer 	    |               | indicates whether the image is of a map or another type of content	| |
|                    |               |              | 0 : index	    | indicates a map index or overview map							| |
| 		                 |         						|              | 1 : is_map	   | indicates a map          |  |
| 		                 |               |              | 2 : not_map	  | indicates non-map content, such as a plate depicting sea monsters		| |
|                    | updated_at    | date, time, & time zone |    | when the map was last updated |  |
|                    | title         |  string       |              | the title of the map |  |
|                    | id            | integer       |              | the unique identifier for the map |  |
|                    | description   | string        |              | the description of the map      |  |
|                    | height        | integer       |              | the height of an unwarped map |
|                    | nypl_digital_id  | integer    |              | the NYPL digital ID used for the thumbnail image and link to the library's metadata | |
|                    | mask_status   | integer	      |               | the status of the mask		| |
| 		                 |               |               | 0 : unmasked		|  the map has not been masked				| |
| 		                 |               |               | 1 : masking		 |  the map is undergoing the masking process				| |
| 		                 |               |               | 2 : masked		  |  the map has been masked				| |
|                    | bbox	         | a comma-separated string of latitude and longitude coordinates   |  | a rectangle delineating the geographic footprint of the map 		|     | 
|                    | width         | integer       |               | the width of an unwarped map | |
|                    | created_at		  | date, time, & time zone	|	    | when the layer was created		|    |
| total_pages		      |               | integer 	     |	              | the total number of pages in the result set		|    |
| per_page		         |               | integer       |	              | the number of search results per page		|    |
| total_entries	     |               | integer 	     |	              | the total number of search results					|    |

###Map and Layer Web Map Services

The following Web map services are available.

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
| GET           |  http://mapwarper.net/maps/{:mapscan_id}/gcps.json or       | 
|               |  http://mapwarper.net/maps/{:mapscan_id}/gcps?format=json   |

Returns a list of the ground control points used to warp a map, as well as their calculated errors.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes     |
| ------------- | ----------  | ----------  | ----------  | --------  | --------- |
| map_id        |             | integer     | the unique identifier for the map   |  required         |       |
| format        |             | string      | specifies output format      |    optional       |  default is HTML     |
|               | json        |             | requests output in JSON format, rather than HTML or XML | optional | |

**Request Examples**

[http://mapwarper.net/maps/8561/gcps.json](http://mapwarper.net/maps/8561/gcps.json) or

[http://mapwarper.net/maps/8561/gcps?format=json](http://mapwarper.net/maps/8561/gcps?format=json)

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

**Response Elements**

| Name          |               | Type        | Description | 
| ------------- | -----------   | ----------- | ----------  | 
| stat          |               | string      | the HTTP response for the status of the request   | 
| items		       |               | array       | an array of key pairs with information about the ground control points 	|			
|               | lon           | big decimal | the longitude of the ground control point           |
|               | updated_at    | date, time, & time zone | the date and time when the ground control point was last updated  |
|               | x             | float       | the x coordinate on the image that corresponds to "lon"   |
|               | y             | float       | the y coordinate on the image that corresponds to "lat"   |
|               | mapscan_id    | integer     | the unique identifier for the map            |
|               | id            | integer     | the unique identifier for the ground control point   |
|               | error         | float       | the calculated root mean square error, or distortion, for the ground control point   | 
|               | lat           | big decimal | the latitude of the ground control point   |
|               | created_at    | date, time, & time zone | the date and time when the ground control point was created   |

If the map is not found, the request will return the following response (when using "format=json").

| Status          | Response |
| --------------- | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

###Get a Single Ground Control Point

| Method       | Definition | 
| ------------ | ---------- | 
| GET          |  http://mapwarper.net/gcps/{:gcp_id}?format=json |

Returns a specified ground control point by ID.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes     |
| ------------- | ----------  | ----------  | ----------  | --------  | --------- |
| gcp_id        |             | integer     | the unique identifier for the ground control point   |  required  |       |
| format        |             | string      | specifies output format      |    optional       |  default is HTML     |
|               | json        |             | requests output in JSON format, rather than HTML or XML | optional |    |

**Example**

[http://mapwarper.net/gcps/9579?format=json](http://mapwarper.net/gcps/{gcp_id}?format=|json)

**Response**

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

| Name          |               | Type        | Description | 
| ------------- | -----------   | ----------- | ----------  | 
| stat          |               | string      | the HTTP response for the status of the request   | 
| items		       |               | array       | an array of key pairs with information about the ground control points 	|			
|               | lon           | big decimal | the longitude of the ground control point           |
|               | updated_at    | date, time, & time zone | the date and time when the ground control points were last updated  |
|               | x             | float       | the x coordinate on the image that corresponds to "lon"   |
|               | y             | float       | the y coordinate on the image that corresponds to "lat"   |
|               | mapscan_id    | integer     | the unique identifier for the map            |
|               | id            | integer     | the unique identifier for the ground control point                |
|               | lat           | big decimal | the latitude of the ground control point   |
|               | created_at    | date, time, & time zone | the date and time when the ground control point was created   |

If the GCP is not found, the request will return the following response (when using "format=json").

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

###Add Ground Control Points

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  http://mapwarper.net/gcps/add/{:map_id} |

Adds the ground control points on which a warp will be based. Requires authentication.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes |
| ------------- | ---------   | ----------- | ----------  | --------  | ----- |                                           
| map_id        |             | integer     | the map to which the new ground control point will be applied        | required |                |
| lat           |             | big decimal | the latitude of the ground control point to warp to                         | optional | default is 0   |
| lon           |             | big decimal | the longitude of the ground control point to warp to                        | optional | default is 0   |
| x             |             | float       | the x coordinate on the unwarped image that corresponds to "lon"     | optional | default is 0   |
| y             |             | float       | the y coordinate on the unwarped image that corresponds to "lat"     | optional | default is 0   | 
| format        |             |  string     | specifies output format                                              | optional | default is HTML |
|               | json        |             | requests output in JSON format, rather than HTML or XML              | optional |                |

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

| Name          |               | Type        | Description | 
| ------------- | -----------   | ----------- | ----------  | 
| stat          |               | string      | the HTTP response for the status of the request   | 
| items		       |               | array       | an array of key pairs with information about the ground control points 	|			
|               | lon           | big decimal | the longitude of the ground control point           |
|               | updated_at    | date, time, & time zone | the date and time when the ground control point was last updated  |
|               | x             | float       | the x coordinate on the image that corresponds to "lon"   |
|               | y             | float       | the y coordinate on the image that corresponds to "lat"   |
|               | mapscan_id    | integer     | the unique identifier for the map            |
|               | id            | integer     | the unique identifier for the ground control point                |
|               | error         | float       | the calculated root mean square error, or distortion, for the ground control point  |
|               | lat           | big decimal | the latitude of the ground control point   |
|               | created_at    | date, time, & time zone | the date and time when the ground control point was created   |

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
| PUT          |  http://mapwarper.net/gcps/update/{:gcp_id} |

Updates all of the fields for a given GCP.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes |
| ------------- | ----------  | ----------  | ----------- | --------- | ----- |
| gcp_id        |             | integer     | the unique identifier for the ground control point  | required  |       |
| lat           |             | big decimal | the latitude of the ground control point to warp to    | optional  | default is 0 |
| lon           |             | big decimal | the longitude of the ground control point to warp to   | optional  | default is 0 |
| x             |             | float       | the x coordinate on the unwarped image that corresponds to "lon"    | optional | default is 0 |
| y             |             | float       | the y coordinate on the unwarped image that corresponds to "lat"    | optional | default is 0 | 
| format        |             | string      | specifies output format      |    optional       |  default is HTML     |
|               | json        |             | requests output in JSON format, rather than HTML or XML | optional | |

**Example**

[http://mapwarper.net/gcps/update/14803](http://mapwarper.net/gcps/update/14803)

**Example using cURL and HTTP BASIC**

```
curl -X PUT -d "lat=54.33&lon=-1.467&x=3666.335&y=2000.12&format=json" -u user@example.com:password http://mapwarper.net/gcps/update/14803
```

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
| PUT           |  http://mapwarper.net/gcps/update_field/{:gcp_id} |

Updates a single field for a GCP. Requires authentication.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes |
| ------------- | ----------  | --------    | ----------  | --------- | ----- |
| gcp_id        |             | integer     | the unique identifier for the ground control point | required |  |
| attribute     |             | string      | indicates the field to update | optional | |
|               | lat         |             | the latitude of the ground control point to warp to   | optional |  |
|               | lon         |             | the longitude of the ground control point to warp to  | optional |  |
|               | x           |             | the x coordinate on the unwarped image that corresponds to "lon"    | optional |  |
|               | y           |             | the y coordinate on the unwarped image that corresponds to "lat"    | optional |  | 
| value         |             | integer     | the new value for "lat," "lon," "x," or "y"  | required |  default is 0  |
| format        |             | string      | specifies output format         | optional     |  default is HTML |
|               | json        |             | requests output in JSON format, rather than HTML or XML   | optional |              |

**Example**

[http://mapwarper.net/gcps/update_field/14803](http://mapwarper.net/gcps/update_field/14803)

**cURL Example**

```
curl -X PUT -d "value=54.33&attribute=lat&format=json" -u user@example.com:password
 http://mapwarper.net/gcps/update_field/14803
 ```

**Response**

An error will appear in the following format.

```
{{{
{"items":[],"errors":[["lat","is not a number"]],"stat":"fail","message":"Could not update GCP"}
}}}
```

If the GCP is not found, the request will return the following response (when using "format=json").

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

###Delete a GCP

| Method        | Definition | 
| ------------- | ---------  | 
| DELETE        |  http://mapwarper.net/gcps/destroy/{:gcp_id} |

Deletes a ground control point. Requires authentication.

**Parameters**

| Name        | Type        | Description | Required  | 
| ----------- | ---------   | ---------   | --------- |
| gcp_id      |  integer    | the unique identifier for the ground control point  |  required |

Example: 

[http://mapwarper.net/gcps/destroy/14805](http://mapwarper.net/gcps/destroy/14805)

**Response**

An error will appear in the following format.

```
{{{
{"items":[],"errors":[["field","message about field"]],"stat":"fail","message":"Could not delete GCP"}

}}}
```

If the GCP is not found, the request will return the following response (when using "format=json").

| Status          | Response |
| -------------   | -------- | 
| 404	(not found) | ```{"items":[],"stat":"not found"}```    |

##Masking

Uses GML to mask a portion of the map. This essentially crops the map. Masking is used to delete the borders around the map images to make a seamless layer of contiguous maps. Requires authentication.

###Get Mask

| Method        | Definition | 
| ------------- | ---------  | 
| GET           |  http://mapwarper.net/shared/masks/{:map_id}.gml.ol |

Gets a GML string containing coordinates for the polygon(s) to mask over.

**Examples**

http://mapwarper.net/shared/masks/7449.gml.ol or

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
| POST          |  http://mapwarper.net/maps/{:map_id}/save_mask |

Saves a mask. Returns a text string with a message indicating success or failure. Requires authentication.

**Parameters**

| Name          |              | Type        | Description  | Required  | Notes |
| ------------- | ---------    | ----------  | ---------    | --------  | ----- |
| map_id        |              |  integer    | the unique indentifer for the map | required  | |
| format        |              |  string     | specifies output format | optional | default is HTML |
|               | json         |             | outputs a GML string of coordinates for the polygon(s) to be masked | optional  | 

**Request Example**

[http://mapwarper.net/maps/7449/save_mask](http://mapwarper.net/maps/7449/save_mask)

**cURL Example**

```
{{{
curl -X POST -d "format=json" -d 'output=<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>' -u user@example.com:pass  http://mapwarper.net/maps/7449/save_mask
}}}
```

**Response**

A successful call will return the following message. 

```
{"stat":"ok", "message":"Map clipping mask saved (gml)"}
```

Using "format=json" will return a GML string of coordinates for the polygon(s) to be masked, such as the following.

```
{{{ feature:geometrygml:Polygongml:outerBoundaryIsgml:LinearRing1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179/gml:coordinates/gml:LinearRing/gml:outerBoundaryIs/gml:Polygon/feature:geometry/feature:features/gml:featureMember/wfs:FeatureCollection }}}
```

###Delete Mask

| Method        | Definition | 
| ------------- | -------    | 
| POST          |  http://mapwarper.net/maps/{:map_id}/delete_mask |

Deletes a mask. Requires authentication.

**Parameters** 

| Name          |             | Type        | Description | Required  | 
| ------------- | ---------   | ---------   | ----------- | --------  |
| map_id        |             | integer     | the unique identifier for the map   |  required  |
| format        |             | string      | specifies output format  | optional |  
|               | json        |             | requests output in JSON format, rather than HTML or XML  | optional |

**Response**

| Status        | Response | Notes |
| ------------- | -------- | ----- |
| 200	(OK)| ```{"stat":"ok","message":"mask deleted"}```    | success |
| 404	(not found) | ```{"items":[],"stat":"not found"}```   | mask not found |


###Mask Map

| Method        | Definition | 
| ------------- | -------    | 
| POST          |  http://mapwarper.net/maps/{:map_id}/mask_map |

Applies the clipping mask to a map, but does not warp it. A clipping mask should be saved before calling this. Requires authentication.

**Response**

| Status        | Response | Notes |
| ------------- | -------  | ----  | 
| 200	(OK) | ```{"stat":"ok","message":"Map cropped"}```    | success                 |
| 404	(not found) | ```{"items":[],"stat":"not found"}```   | clipping mask not found |

###Save, Mask, and Warp Map

| Method       | Definition | 
| ------------ | --------   | 
| POST         |  http://mapwarper.net/maps/{:map_id}/save_mask_and_warp |

Rolls the calls into one. Saves the mask, applies the mask to the map, and warps the map using the mask. Requires authentication.

**Parameters**

| Name        | Type        | Description | Required  |
| ----------- | ----------- | ----------  | --------- |
| map_id      | integer     | the unique identifier for the map | required |

**Response**

The output will be a GML string containing the coordinates of the polygon(s) to mask over.

| Status        | Response | Notes |
| ------------- | -------  | ----- |
| 200	(OK) | ```{"stat":"ok","message":"Map masked and rectified!"}```    | success |
| 200	(OK )| ```{"stat":"ok","message":"Map masked but it needs more control points to rectify"}```    | returned when a map has less than three GCPs |
| 404	(not found) | ```{"items":[],"stat":"not found"}```    | no clipping mask found |

###Warping

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  http://mapwarper.net/maps/{:map_id}/rectify |

Warps or rectifies a map according to its saved GCPs and the parameters passed in. Requires authentication.

**Example:**

[http://mapwarper.net/maps/7449/rectify](http://mapwarper.net/maps/7449/rectify)

**Curl Example**

```
curl -X POST -d "use_mask=false&format=json" -u email@example.com:password  http://mapwarper.net/maps/7449/rectify
```

**Parameters**

| Name      	    |       | Type  | Description  |  Required | Notes  |
| -----          | ----- | ----- | ---------    |  -----    | ------ |
| map_id      		 |       | integer  | the unique identifier for the map   | required |  |
| use_mask		     |       | boolean  | applies any saved mask to the map | optional | default is false     |
| format         |       | string   | specifies output format           | optional |  default is HTML     |
|                | json  |          | requests output in JSON format, rather than HTML or XML | optional | |

**Other Parameters**

The following options specify the algorithm or method that should be used to warp a map.

| Name      	       |                | Type    | Description            |  Required | Notes  |
| -----             | -------------  | ------- | ---------              |  -------  | -----  |
| resample_options  |                | string  |                        | optional  |        |         
|                   | near      		   |         | nearest neighbor       | optional  | fastest processing; default |
|                   | bilinear		     |         | bilinear interpolation | optional  |                         |
|                   | cubic 		       |         | cubic                  | optional  | good option, but slower | 
|                   | cubicspline	   |         | cubic spline           | optional  | slowest; best quality   | 
| transform_options |                | string  |                        | optional  |        |
|                   | auto     		    |         |                        | optional  | default |
|                   | p1		           |         | 1st order polynomial   | optional |  requires a minimum of 3 GCPs   |
|                   | p2 		          |         | 2nd order polynomial   | optional |  requires a minimum of 6 GCPs   | 
|                   | p3	            |         | 3rd order polynomial   | optional |  requires a minimum of 10 GCPs   | 
|                   | tps	           |         | thin plate spline      | optional |  requires many evenly-distributed GCPs |

**Response**

| Status          | Response | Notes |
| -------------   | -------  | ----- |
| 200	(OK)        | ```{"stat":"ok","message":"Map rectified."}```    | success  |
|                 | ```{"stat":"fail","message":"not enough GCPS to rectify"}``` | map doesn't have enough GCPs saved |
| 404	(not found) | ```{"items":[],"stat":"not found"}```    | map not found |
