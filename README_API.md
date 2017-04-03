#Warper API Documentation



Welcome to the documentation for the Warper API! MapWarper is a free application that assigns the proper geographic coordinates to scanned maps in image formats. Users can upload images, then assign ground control points to match them up with a base map. Once MapWarper warps or stretches the image to match the corresponding extent of the base map, it can be aligned and displayed with other maps, and used for digital geographic analysis. You can access all of the functionality through the API. 

# Table of Contents

- [API Endpoint](#api-endpoint)    
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
[List and Sort Control Points](#list-and-sort-control-points)  
[Get a Map's Ground Control Points](#get-a-maps-ground-control-points)    
[Get a Single Ground Control Point](#get-a-single-ground-control-point)    
[Add Ground Control Points](#add-ground-control-points)    
[Update a GCP](#update-a-gcp)  
[Delete a GCP](#delete-a-gcp)  
[Masking](#masking)  
[Get Mask](#get-mask)  
[Save Mask](#save-mask)  
[Delete Mask](#delete-mask)  
[Mask Map](#mask-map)  
[Save, Mask, and Warp Map](#save-mask-and-warp-map)  
[Warping](#warping)  
[Create Map](#create-map)  
[Update Map](#update-map)  
[Destroy Map](#destroy-map)  
[Publish Map](#publish-map)  
[Unpublish Map](#unpublish-map)  
[Add Many GCPs](#add-many-gcps)  
[Create Layer](#create-layer)  
[Update Layer](#update-layer)  
[Destroy Layer](#update-layer)  
[Toggle Layer Visibility](#toggle-layer-visibility)  
[Remove Map From Layer](#remove-map-from-layer)  
[Merge Layers](#merge-layers)  
[Get User](#get-user)  
[List Users](#list-users)  
[Imports](#imports)  
[Show Import](#show-import)  
[List Import Maps](#list-import-maps)  
[List Imports](#list-imports)  
[Create Import](#create-import)  
[Update Import](#update-import)  
[Destroy Import](#destroy-import)  
[Activity & Stats](#activity)  
[List Activity](#list-activity)  
[List All Maps Activity](#list-maps-activity)  
[List Map Activity](#list-map-activity)  
[List User Activity](#list-user-activity)  
[User Statistics](#user-statistics)  


## Api-Endpoint

`/api/v1`

##Protocol

Both http and https calls work. If you call a https resource, then links within the JSON response should also have https protocols, if you call it via http then the links should be in http. Note that OAuth authentication is configured for https only.

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

###Authentication Token

To authenticate using an email and password to retrieve an authentication token.

| Method        | Definition |
| ------------- | ---------  |
| POST           | /api/v1/auth/sign_in.json |

**Parameters**

| Name     | Type   | Description          | Required | Notes |
|----------|--------|----------------------|----------|-------|
| email    | string | Email of the user    | required |       |
| password | string | Password of the user | required |       |

**Curl Example***

```
curl -X POST http://mapwarper.net/api/v1/auth/sign_in.json -H "Content-Type: application/json" -d '{"user":{"email":"user@example.com","password":"userpassword"}}' -v
```

**Response**

A successful response returns the user as JSON in the data element and the authentication token in a meta element

```
{
  "data": {
    "id": "2",
    "type": "users",
    "attributes": {
      "login": "tim",
      "created_at": "2010-08-26T15:37:34.619Z",
      "enabled": true,
      "provider": null
    },
    "links": {
      "self": "http://mapwarper.net/api/v1/users/2"
    }
  },
  "meta": {
    "auth_token": "BSNSJK3939sbascsc"
  }
}
```

if unauthorized returns a 401 status with
```
{"error":"Invalid email or password."}
```

###Sign out

To sign out which deletes the authentication token.
Authentication is required.

| Method        | Definition |
| ------------- | ---------  |
| DELETE           | /api/v1/auth/sign_out.json |


**Curl Example***

```
curl -X DELETE http://mapwarper.net/api/v1/auth/sign_out.json -H -H 'X-User-Token: longtoken' -H 'X-User-Id: 2' "Content-Type: application/json" -v
```

**Response**

A successful response returns a 200 OK status and an empty hash `{}`

An unsuccessful response returns a 422 unprocessable entity status and an empty hash `{}`


###Validate Token

This is a call to check if an authentication token is still valid. (Signing in and out both reset tokens)


| Method        | Definition |
| ------------- | ---------  |
| GET           | /api/v1/auth/validate_token.json |

**Parameters**

| Name     | Type   | Description          | Required | Notes |
|----------|--------|----------------------|----------|-------|
| email    | string | Email of the user    | required |       |
| password | string | Password of the user | required |       |

**Curl Example***

```
curl -X POST http://mapwarper.net/api/v1/auth/sign_in.json -H "Content-Type: application/json" -H 'Accept: application/json' -d '{"user":{"email":"user@example.com","password":"userpassword"}}' -v
```

**Response**

A successful response returns the user as JSON in the data element and the authentication token in a meta element

```
{
  "data": {
    "id": "2",
    "type": "users",
    "attributes": {
      "login": "tim",
      "created_at": "2010-08-26T15:37:34.619Z",
      "enabled": true,
      "provider": null
    },
    "links": {
      "self": "http://mapwarper.net/api/v1/users/2"
    }
  },
  "meta": {
    "auth_token": "longtoken"
  }
}
```

if unauthorized returns a 401 status with
```
{"error":"Invalid email or password."}
```

##Using the authentication token

You can authentication via the token in two ways

1. Recommended: setting  `X-User-Id` and `X-User-Token` in the header

```
curl  -H 'X-User-Token: longtoken' -H 'X-User-Id: 2' -X GET http://mapwarper.net/api/v1/users/2.json -v
```

2. Passing `user_id` and `user_token` as parameters (handy for GET requests)

```
curl  -X GET http://mapwarper.net/api/v1/users/2.json?user_id=2&user_token=longtoken -v

```

###Oauth Authenticaton and Authentication Token

Instead of using an email and password, a user can login via OUath with Github, twitter, google, and Wikimedia Commons for example. 
This is the way a third party JavaScript application can work with OAuth and the warper

> ** Note: The Oauth path is `/u/auth/{:provider}` and not within the api namespace. This may change.


| Method        | Definition |
| ------------- | ---------  |
| GET           | /u/auth/{:provider} |

**Parameters**

| Name     | Type   | Description          | Required | Notes                                              |
|----------|--------|----------------------|----------|-------                                             |
| privoder | string | Oauth Provider       | required | one of "github", "mediawiki", "twitter", "osm "etc |


The process uses the Browser postMessage API to communicate across windows.

See https://github.com/timwaters/warper_oauth_token_auth_demo  for an example app that uses JToker Jquery library for authentication.

Example JS code:

```
// create popup window
var domain = 'https://mapwarper.net';
var myPopup = window.open(domain + '/u/auth/mediawiki?omniauth_window_type=newWindow&auth_origin_url=' + window.location.href, 'myWindow');

// periodical message sender
var messenger = setInterval(function() {
  var message = 'requestCredentials';
  //send the message and target URI
  myPopup.postMessage(message, domain);
}, 500);

// listen to response
window.addEventListener('message', function(event) {
  // the message listener get's triggered by any URL make sure it's the right one
  if (event.origin !== domain) return;
  clearInterval(messenger);
  console.log(event.data);
}, false);
```


The warper renders /app/views/devise/omniauth_external_window.erb.html

The following gets rendered when the user successfully allows the request:

```
var data;
window.addEventListener("message", function(ev) {
  if (ev.data === "requestCredentials") {
      data = {
       message: "deliverCredentials", 
       auth_token: 'longtoken', 
       uid: '1234', 
       id: '23',
       name: 'Username',
       email: 'Username@example.com',
       provider: 'mediawiki '
   }

    ev.source.postMessage(data, '*');
   window.close();
  }
});
function requestCredentials() {
  return data;
}
```

Then, using the id and the email from the message, API response can be crafted. See https://github.com/timwaters/warper_oauth_token_auth_demo  for an example app.


###Cookie Authentication

The API can also be authenticated with cookies (for example a user logged into the warper in the browser can call the API GET requests in the browser).

**Curl Examples for Email and Password authentication and cookies**

```
curl -X POST http://mapwarper.net/u/sign_in.json -H "Content-Type: application/json"  -H 'Accept: application/json' -d '{"user":{"email":"tim@example.com","password":"password"}}' -c cookie
```

if successful, returns logged in user as jsonapi 

```
{
  "data": {
    "id": "2",
    "type": "users",
    "attributes": {
      "login": "tim",
      "created_at": "2010-08-26T15:37:34.619Z",
      "enabled": true,
      "provider": null
    }"links": {
      "self": "http://mapwarper.net/api/v1/users/2"
    }
  }
}
```

if unauthorized returns a 401 status with
```
{"error":"Invalid email or password."}
```

Example using the cookie:

```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET http://mapwarper.net/api/v1/users/2.json -b cookie
```

Unauthorized calls may return

| Status        | Response |
| ------------- | -------- | 
| 402	(unauthorized) | `{"errors":[{"title":"Unauthorized","detail":"Unauthorized Request"}]}`   |


##Search for Maps

| Method        | Definition |
| ------------- | ---------  |
| GET           | /api/v1/maps.json?query=london | 

Returns a list of maps that meet search criteria (where the title or description contains "london")
No authentication required.

**Parameters**

| Name        | values      | Type    | Description                                                             | Required | Notes                                             |
|-------------|-------------|---------|-------------------------------------------------------------------------|----------|---------------------------------------------------|
| query       |             | string  | search query                                                            | optional |                                                   |
| field       |             | string  | specified field to be searched                                          | optional | default is title                                  |
|             | title       | string  | the title of the map                                                    | optional | default                                           |
|             | description | string  | the description of the map                                              | optional |                                                   |
|             | publisher   | string  | the publisher                                                           | optional |                                                   |
|             | author      | string  | the author of the map                                                   | optional |                                                   |
|             | status      | string  | the status                                                              | optional |                                                   |
|             | page_id     | string  | the wiki page_id                                                        | optional | exact match only, page_ids are numbers            |
| sort_key    |             |         | the field that should be used to sort the results                       | optional | default is updated_at                             |
|             | title       | string  | the title of the map                                                    | optional |                                                   |
|             | updated_at  | string  | when the map was last updated                                           | optional | default                                           |
|             | created_at  | string  | when the map was created                                                | optional |                                                   |
|             | status      | string  | the status of the map                                                   | optional | ordered by integer (see below)                    |
|             | page_id     | string  | the wiki page_id                                                        | optional |                                                   |
| sort_order  |             | string  | the order in which the results should appear                            | optional | default is desc                                   |
|             | asc         |         | ascending order                                                         | optional |                                                   |
|             | desc        |         | descending order                                                        | optional | default                                           |
| show_warped |             | integer | limits to maps that have already been warped                            | optional |                                                   |
|             | 1           | integer | limits to maps that have already been warped                            | optional |                                                   |
|             | 0           | integer | gets all maps, warped and unwarped                                      | optional | default                                           |
| format      |             | string  | specifies output format                                                 | optional | can also be passed in as extension, eg. maps.json |
|             | json        | string  | JSON format for maps                                                    | optional | default                                           |
|             | geojson     | string  | GeoJSON format for maps                                                 | optional | simple array, not featurecollection               |
| page        |             | integer | the page number; use to get the next or previous page of search results | optional |                                                   |
| per_page    |             | integer | number of results per page                                              | optional | default is 50                                     |
| bbox	      | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited | optional |
| operation   |             | string  | specifies how to apply the bounding box  | optional  | default is intersect |
|             | intersect   | string  |uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter  | optional | preferred; orders results by proximity to the bbox extent; default |
|             | within      | string	| uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter  | optional      |  |
 

Notes: Enter optional text for the query, based on the search field chosen. The query text is case insensitive. This is a simple exact string text search. For example, a search for "city New York" returns no results, but a search for "city of New York" returns 22. However, a query for page_id is exact. bbox format is y.min(lon min),x.min(lat min),y.max(lon max), x.max(lat max)



**Example json format**
```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET 'http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1'
```
[http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1)

Example searching within a bounding box

[http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&bbox=-75.9831134505588,38.552727388127,-73.9526411829395,40.4029389105122)


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
			"mask_status": "unmasked",
			"created_at": "2016-02-07T17:52:19.479Z",
			"updated_at": "2016-04-10T17:00:36.586Z",
			"bbox": "26.66587052714201,58.33686848133336,26.806590271771057,58.407077366797424",
			"map_type": "is_map",
			"source_uri": "http://commons.wikimedia.beta.wmflabs.org/wiki/File:Tartu_turismiskeem.png",
			"unique_id": "Tartu_turismiskeem.png",
			"page_id": "52021",
			"date_depicted": "",
			"image_url": "http://upload.beta.wmflabs.org/wikipedia/commons/4/44/Tartu_turismiskeem.png",
			"thumb_url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/4/44/Tartu_turismiskeem.png/100px-Tartu_turismiskeem.png"
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
			"added_by": {
				"data": {
					"id": "2",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/maps/260",
			"gcps_csv": "http://mapwarper.net/maps/260/gcps.csv",
			"mask": "http://mapwarper.net/mapimages/260.gml.ol",
			"geotiff": "http://mapwarper.net/maps/260/export.tif",
			"png": "http://mapwarper.net/maps/260/export.png",
			"aux_xml": "http://mapwarper.net/maps/260/export.aux_xml",
			"kml": "http://mapwarper.net/maps/260.kml",
			"tiles": "http://mapwarper.net/maps/tile/260/{z}/{x}/{y}.png",
			"wms": "http://mapwarper.net/maps/wms/260?request=GetCapabilities\u0026service=WMS\u0026version=1.1.1"
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
			"self": "http://mapwarper.net/api/v1/layers/43"
		}
	}, {
		"id": "44",
		"type": "layers",
		"attributes": {
			"name": "Category:Tartu Maps",
			"description": null
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/layers/44"
		}
	}],
	"links": {
      "self":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=1\u0026page%5Bsize%5D=2\u0026per_page=2",
      "next":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=2\u0026page%5Bsize%5D=2\u0026per_page=2",
      "last":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=3\u0026page%5Bsize%5D=2\u0026per_page=2"
  },
	"meta": {
		"total_entries": 5,
		"total_pages": 2
	}
}
```


**Response Elements**

***Data***

An array of maps, each having an attributes object and, id and type and links

| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the map             |       |  
| type          |    maps       | the type of resource            |      |  
| links         |               | links to the resource, and export links |   |   
| attributes    |               | Attributes of the map | see separate table for more detail   |  
| relationships | layers, added_by | the layers that the map belongs to and the user that uploaded it | (see included) |  
| included      |               | Details about the layers  |   |   

***Links***

The top level links holds pagination links

```
"links": {
    "self":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=1\u0026page%5Bsize%5D=2\u0026per_page=2",
    "next":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=2\u0026page%5Bsize%5D=2\u0026per_page=2",
    "last":"http://mapwarper.net/api/v1/maps?format=json\u0026page%5Bnumber%5D=3\u0026page%5Bsize%5D=2\u0026per_page=2"
},
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```
indicates that 50 results have been found over 2 pages.

| Value | Description |
| ------| -------     |
| total_entries | the total number of maps found for this request |
| total_pages |  the total number of pages found |

***Map Links***

| Value | Description |
| ------| -------     |
| gcps_csv| CSV for the control points |
| mask |  the GML clipping mask |
| geotiff | The export GeoTiff url |
| png |The export PNG url |
| aux_xml | The export PNG XML url |
| kml | The export KML url |
| tiles | The Tiles template |
| wms | The WMS getCapabilities endpoint |  

 
***Attributes***

| Name          | Type     | Value     | Description                                                        | Notes              |   
|---------------|----------|-----------|--------------------------------------------------------------------|--------------------|  
| status        | string   |           | the status of the map                                              |                    |   
|               |          | unloaded  | the map has not been loaded                                        |                    |   
|               |          | loading   | the master image is being requested from the NYPL repository       |                    |   
|               |          | available | the map has been copied and is ready to be warped                  |                    |   
|               |          | warping   | the map is undergoing the warping process                          |                    |   
|               |          | warped    | the map has been warped                                            |                    |   
|               |          | published | this status is set when the map should no longer be edited         |                    |   
| map_type      | string   |           | indicates whether the image is of a map or another type of content |                    |   
|               |          | index     | indicates a map index or overview map                              |                    |   
|               |          | is_map    | indicates a map                                                    | default            |   
|               |          | not_map   | indicates non-map content, such as a plate depicting sea monsters  |                    |   
| updated_at    | datetime |           | when the map was last updated                                      |                    |   
| created_at    | datetime |           | when the map was first created                                     |                    |   
| title         | string   |           | the title of the map                                               |                    |   
| description   | string   |           | the description of the map                                         |                    |   
| height        | integer  |           | the height of an unwarped map                                      |                    |   
| width         | integer  |           | the width of an unwarped map                                       |                    |   
| mask_status   | string   |           | the status of the mask                                             |                    |   
|               |          | unmasked  | the map has not been masked                                        |                    |   
|               |          | masking   | the map is undergoing the masking process                          |                    |   
|               |          | masked    | the map has been masked                                            |                    |   
| source_uri    | string   |           | the URI to the source map page                                     | e.g. the wiki page |   
| unique_id     | string   |           | the image filename taken from the source image                     |                    |   
| page_id       | integer  |           | The Wiki PAGEID for the source                                     |                    |   
| date_depicted | string   |           | string representation of the date that the map depicts             |                    |   
| image_url     | string   |           | URL to the original full size image                                |                    |   
| thumb_url     | string   |           | URL to the thumbnail                                               | 100px dimension    |   
| bbox	        | comma-separated string of lat & lon coords |  | a rectangle delineating the geographic area to which the search should be limited |  |  




**Example geojson format**

```
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET 'http://mapwarper.net/api/v1/maps?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1&format=geojson'
```
[http://mapwarper.net/api/v1/maps.geojson?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1](http://mapwarper.net/maps?api/v1/maps.geojson?field=title&query=Tartu&sort_key=updated_at&sort_order=desc&show_warped=1)

***Response***

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
| GET           | /api/v1/maps/{:id}.{:format} or     | 
|               | /api/v1/maps/{:id}?format={:format} |

Returns a map by ID.
No authentication required.

**Parameters**

 
| Name          |              | Type         | Description					                | Required    | Notes |   
| ------        | -------     | ------        | -------                             |  -------     |  -------  |
| id  		      |              | integer 	     | the unique identifier for a map    | required		  |       |
| format  		  |              | string 	     | specifies output format            | optional		  | default JSON  |
|               | json / geojson |             | use to specify JSON output formart  | optional |  |


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
			"mask_status": "unmasked",
			"created_at": "2015-10-20T17:17:58.300Z",
			"updated_at": "2016-06-08T10:55:13.660Z",
			"bbox": "-7.706061311682345,49.02738371829112,3.420945210059412,56.46163780182066",
			"map_type": "is_map",
			"source_uri": "http://commons.wikimedia.beta.wmflabs.org/wiki/File:Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"unique_id": "Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"page_id": "51038",
			"date_depicted": "",
			"image_url": "http://upload.beta.wmflabs.org/wikipedia/commons/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg",
			"thumb_url": "http://upload.beta.wmflabs.org/wikipedia/commons/thumb/2/29/Lawrence-h-slaughter-collection-of-english-maps-england.jpeg/100px-Lawrence-h-slaughter-collection-of-english-maps-england.jpeg"
		},
		"relationships": {
			"layers": {
				"data": [{
					"id": "1",
					"type": "layers"
				}]
			},
			"added_by": {
				"data": {
					"id": "5",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/maps/2",
			"gcps_csv": "http://mapwarper.net/maps/2/gcps.csv",
			"mask": "http://mapwarper.net/mapimages/2.gml.ol",
			"geotiff": "http://mapwarper.net/maps/2/export.tif",
			"png": "http://mapwarper.net/maps/2/export.png",
			"aux_xml": "http://mapwarper.net/maps/2/export.aux_xml",
			"kml": "http://mapwarper.net/maps/2.kml",
			"tiles": "http://mapwarper.net/maps/tile/2/{z}/{x}/{y}.png",
			"wms": "http://mapwarper.net/maps/wms/2?request=GetCapabilities\u0026service=WMS\u0026version=1.1.1"
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
			"self": "http://mapwarper.net/api/v1/layers/1"
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

***Data***


| Name          | Value            | Description                                                      | Notes                              |   
|---------------|------------------|------------------------------------------------------------------|------------------------------------| 
| id            |                  | The id for the map                                               |                                    |   
| type          | maps             | the type of resource                                             |                                    |   
| links         |                  | links to the resource, and export links                          |                                    |   
| attributes    |                  | Attributes of the map                                            | see separate table for more detail |   
| relationships | layers, added_by | the layers that the map belongs to and the user that uploaded it | (see included)                     |   
| included      |                  | Details about the layers                                         |                                    |   


***Map Links***

| Value | Description |
| ------| -------     |
| gcps_csv| CSV for the control points |
| mask |  the GML clipping mask |
| geotiff | The export GeoTiff url |
| png |The export PNG url |
| aux_xml | The export PNG XML url |
| kml | The export KML url |
| tiles | The Tiles template |
| wms | The WMS getCapabilities endpoint |  

***Attributes***

| Name          | Type     | Value     | Description                                                        | Notes              |   
|---------------|----------|-----------|--------------------------------------------------------------------|--------------------|  
| status        | string   |           | the status of the map                                              |                    |   
|               |          | unloaded  | the map has not been loaded                                        |                    |   
|               |          | loading   | the master image is being requested from the NYPL repository       |                    |   
|               |          | available | the map has been copied and is ready to be warped                  |                    |   
|               |          | warping   | the map is undergoing the warping process                          |                    |   
|               |          | warped    | the map has been warped                                            |                    |   
|               |          | published | this status is set when the map should no longer be edited         |                    |   
| map_type      | string   |           | indicates whether the image is of a map or another type of content |                    |   
|               |          | index     | indicates a map index or overview map                              |                    |   
|               |          | is_map    | indicates a map                                                    | default            |   
|               |          | not_map   | indicates non-map content, such as a plate depicting sea monsters  |                    |   
| updated_at    | datetime |           | when the map was last updated                                      |                    |   
| created_at    | datetime |           | when the map was first created                                     |                    |   
| title         | string   |           | the title of the map                                               |                    |   
| description   | string   |           | the description of the map                                         |                    |   
| height        | integer  |           | the height of an unwarped map                                      |                    |   
| width         | integer  |           | the width of an unwarped map                                       |                    |   
| mask_status   | string   |           | the status of the mask                                             |                    |   
|               |          | unmasked  | the map has not been masked                                        |                    |   
|               |          | masking   | the map is undergoing the masking process                          |                    |   
|               |          | masked    | the map has been masked                                            |                    |   
| source_uri    | string   |           | the URI to the source map page                                     | e.g. the wiki page |   
| unique_id     | string   |           | the image filename taken from the source image                     |                    |   
| page_id       | integer  |           | The Wiki PAGEID for the source                                     |                    |   
| date_depicted | string   |           | string representation of the date that the map depicts             |                    |   
| image_url     | string   |           | URL to the original full size image                                |                    |   
| thumb_url     | string   |           | URL to the thumbnail                                               | 100px dimension    |   
| bbox	        | comma-separated string of lat & lon coords |  | a rectangle delineating the geographic area to which the search should be limited |  |  




**Not Found Error**

If the map is not found, the request will return the following response.

| Status        | Response |
| ------------- |----------| 
| 404	(not found)| ```{"errors":[{"title":"Not found","detail":"Couldn't find Map with 'id'=2222"}]}```    |

###Get a Map's Status

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/maps/{:id}/status |

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
| ------        | -------     | ------   | -------                             |  -------     | 
| status	       | string	   | 	      | the status of the map             |       |
| 	             | 	         | unloaded	| the map has not been loaded					    |
| 		            |		       | loading 	| the master image is being requested from the NYPL repository	| |
| 		            | 		     | available| the map has been copied, and is ready to be warped	|   |
| 		            | 		     |  warping	| the map is undergoing the warping process			|  |
| 		            | 		     |  warped	| the map has been warped					  |       |
| 		            | 		     |  published	| this status is set when the map should no longer be edited | |


------------------------------

##Layers

A layer is a mosaic in which the component maps are stitched together and displayed as one seamless map. Layers are often comprised of contiguous maps from the facing pages of a scanned book. For examples of layers, see the [Plan of the town of Paramaribo, capital of Surinam](http://maps.nypl.org/warper/layers/1450) or the map of New York City and Vicinity at [http://maps.nypl.org/warper/layers/1404](http://maps.nypl.org/warper/layers/1404).
No authentication required.

> ** Note: in the mapwarper application Layers are often called "Mosaics"

###Query or List Layers

| Method       | Definition | 
| ------------ | -------    | 
| GET          | /api/v1/layers |

**Parameters**

| Name       | values      | Type    | Description                                                             | Required | Notes                                             |
|------------|-------------|---------|-------------------------------------------------------------------------|----------|---------------------------------------------------|
| query      |             | string  | search query                                                            | optional |                                                   |
| field      |             | string  | specified field to be searched                                          | optional | default is title                                  |
|            | name        | string  | the title of the layer                                                  | optional | default                                           |
|            | description | string  | the description of the layer                                            | optional |                                                   |
| sort_key   |             |         | the field that should be used to sort the results                       | optional | default is updated_at                             |
|            | name        | string  | the name of the layer                                                   | optional |                                                   |
|            | updated_at  | string  | when the layer was last updated                                         | optional | default                                           |
|            | created_at  | string  | when the layer was created                                              | optional |                                                   |
|            | percent     | string  | the percent of maps which are rectified in the layer                    | optional | ordered by integer (see below)                    |
| sort_order |             | string  | the order in which the results should appear                            | optional | default is desc                                   |
|            | asc         |         | ascending order                                                         | optional |                                                   |
|            | desc        |         | descending order                                                        | optional | default                                           |
| format     |             | string  | specifies output format                                                 | optional | can also be passed in as extension, eg. maps.json |
|            | json        | string  | JSON format for layer                                                   | optional | default                                           |
|            | geojson     | string  | GeoJSON format for layer                                                | optional | simple array, not featurecollection               |
| page       |             | integer | the page number; use to get the next or previous page of search results | optional |                                                   |
| per_page   |             | integer | number of results per page                                              | optional | default is 50                                     |
| bbox	     | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited | optional |  |  
| operation  |           | string       | specifies how to apply the bounding box  | optional  | default is intersect |
|            | intersect | string       |uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter  | optional | preferred; orders results by proximity to the bbox extent; default |
|            | within    | string	      | uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter  | optional      |   |  
 

Notes: Enter optional text for the query, based on the search field chosen. The query text is case insensitive. This is a simple exact string text search. For example, a search for "city New York" returns no results, but a search for "city of New York" returns 22. bbox format is y.min(lon min),x.min(lat min),y.max(lon max), x.max(lat max)


**Request Example**

[http://mapwarper.net/api/v1/layers?query=tartu](http://mapwarper.net/api/v1/layers?query=tartu)

**Response**

```
{
	"data": [
		{
			"id": "3",
			"type": "layers",
			"attributes": {
				"name": "Category:Tartu Maps",
				"description": null,
				"created_at": "2016-02-09T13:34:15.355Z",
				"updated_at": "2016-04-04T16:20:52.442Z",
				"bbox": "26.111586,58.232919,27.358788,58.486400",
				"maps_count": 1,
				"rectified_maps_count": 1,
				"is_visible": true,
				"source_uri": "https://commons.wikimedia.org/wiki/Category:Tartu Maps",
				"rectified_percent": 100
			},
			"relationships": {
				"maps": {
					"data": [
						{
							"id": "6",
							"type": "maps"
						}
					]
				}
			},
			"links": {
				"self": "http://mapwarper.net/api/v1/layers/3",
				"kml": "http://mapwarper.net/layers/3.kml",
				"tiles": "http://mapwarper.net/layers/tile/#/{z}/{x}/{y}.png",
				"wms": "http://mapwarper.net/layers/wms/3?request=GetCapabilities&service=WMS&version=1.1.1"
			}
		}],
"links": {
		"self": "http://mapwarper.net/api/v1/layers?page%5Bnumber%5D=1&page%5Bsize%5D=1&per_page=1&query=tartu",
		"next": "http://mapwarper.net/api/v1/layers?page%5Bnumber%5D=2&page%5Bsize%5D=1&per_page=1&query=tartu",
		"last": "http://mapwarper.net/api/v1/layers?page%5Bnumber%5D=2&page%5Bsize%5D=1&per_page=1&query=tartu"
	},
	"meta": {
		"total_entries": 2,
		"total_pages": 2
	}
```

**Response Elements**


***Data***

An array of matching layers, each having an attributes object and, id and type and links

| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the layer             |       |  
| type          |    layers       | the type of resource            |      |  
| links         |               | links to the resource, and export links |   |   
| attributes    |               | Attributes of the layer | see separate table for more detail   |  
| relationships | maps  | the maps that the layer has  | (see getting a layers maps) |   


***Links***

The top level links holds pagination links. Shown if there are more results than are contained in the response.

```
"links": {
    "self":"http://mapwarper.net/api/v1/layers?format=json\u0026page%5Bnumber%5D=1\u0026page%5Bsize%5D=2\u0026per_page=2",
    "next":"http://mapwarper.net/api/v1/layers?format=json\u0026page%5Bnumber%5D=2\u0026page%5Bsize%5D=2\u0026per_page=2",
    "last":"http://mapwarper.net/api/v1/layers?format=json\u0026page%5Bnumber%5D=3\u0026page%5Bsize%5D=2\u0026per_page=2"
},
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps, Shown if there are more results than are contained in the response.

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```
indicates that 50 results have been found over 2 pages.

| Value | Description |
| ------| -------     |
| total_entries | the total number of layers found for this request |
| total_pages |  the total number of pages found |


***Layer Links***

| Value | Description |
| ------| -------     |
| self  | the API link to the resourece |
| kml | The export KML url |
| tiles | The Tiles template |
| wms | The WMS getCapabilities endpoint |  

***Attributes***

| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| name               | string      | the title of the layer |  |
| description        | string      |  description of layer  |  |
| is_visible          | boolean/string		   | if false, usually indicates a meta-layer or collection of atlases | these meta-layers will not have WMSs   |
| maps_count        | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable    |
| rectified_maps_count    | integer   | how many maps in the layer are warped	|    |
| rectified_percent  | integer | the percentage of maps that are warped    |  |
| bbox	              | a comma-separated string of latitude and longitude coordinates   | a rectangle delineating the geographic footprint of the layer 		|     | 
| source_uri         | string | the URI to the source layer page  | e.g. the Wiki Category that the layer/mosaic represents |
| created_at		      | date, time, & time zone 	|		when the layer was created in the system		|    |
| updated_at         | date, time, & time zone  | when the layer was last updated |  |


###Get Layer

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/layers/{:id} or |
|              |  /api/v1/layers/{:id}.json |

Returns a single layer.

**Parameters**

| Name          |             | Type      | Description | Required  | Notes     |
| ------------- | ----------  | --------  | ----------  | --------- | --------- |
| id      |             | integer        | the unique identifier for the layer   |  required   |                 |
| format        |             | string    | specifies output format               |  optional   | default is json |
|               | json or geosjon    |           |           | optional |      |

**Request Examples**

[http://mapwarper.net/api/v1/layers/2](http://mapwarper.net/api/v1/layers/2) 


**Response**

```
{
	"data": {
		"id": "2",
		"type": "layers",
		"attributes": {
			"name": "Category:Maps Of Tartu",
			"description": null,
			"created_at": "2015-11-12T10:56:25.461Z",
			"updated_at": "2016-04-04T16:20:52.354Z",
			"bbox": "26.111586,58.232919,27.358788,58.486400",
			"maps_count": 2,
			"rectified_maps_count": 1,
			"is_visible": true,
			"source_uri": "https://commons.wikimedia.org/wiki/Category:Maps Of Tartu",
			"rectified_percent": 50
		},
		"relationships": {
			"maps": {
				"data": [{
					"id": "5",
					"type": "maps"
				}, {
					"id": "6",
					"type": "maps"
				}]
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/layers/2",
			"kml": "http://mapwarper.net/layers/2.kml",
			"tiles": "http://mapwarper.net/layers/tile/#/{z}/{x}/{y}.png",
			"wms": "http://mapwarper.net/layers/wms/2?request=GetCapabilities&service=WMS&version=1.1.1"
		}
	}
}
```
**Response Elements**

***Data***


| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the layer             |       |  
| type          |    layers       | the type of resource            |      |  
| links         |               | links to the resource, and export links |  see Links  |   
| attributes    |               | Attributes of the layer | see separate table for more detail   |  
| relationships | layers, added_by | the maps that are in the layer |  |   


***Links***

| Value | Description |
| ------| -------     |
| self  | the API link to the resourece |
| kml | The export KML url |
| tiles | The Tiles template |
| wms | The WMS getCapabilities endpoint |  

***Attributes***

| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| name               | string      | the title of the layer |  |
| description        | string      |  description of layer  |  |
| is_visible          | boolean/string		   | if false, usually indicates a meta-layer or collection of atlases | these meta-layers will not have WMSs   |
| maps_count        | integer   | how many maps a layer has, as opposed to title pages, plates, and other non-map content	| defines a map using the map_type => is_map variable    |
| rectified_maps_count    | integer   | how many maps in the layer are warped	|    |
| rectified_percent  | integer | the percentage of maps that are warped    |  |
| bbox	              | a comma-separated string of latitude and longitude coordinates   | a rectangle delineating the geographic footprint of the layer 		|     | 
| source_uri         | string | the URI to the source layer page  | e.g. the Wiki Category that the layer/mosaic represents |
| created_at		      | date, time, & time zone 	|		when the layer was created in the system		|    |
| updated_at         | date, time, & time zone  | when the layer was last updated |  |



**Not Found Error**

If the layer is not found, the request will return the following response.

| Status        | Response |
| ------------- |----------| 
| 404	(not found)| ```{"errors":[{"title":"Not found","detail":"Couldn't find Layer with 'id'=1234"}]}```    |




###GeoJSON format
[http://mapwarper.net/api/v1/layers/2.geojson](http://mapwarper.net/api/v1/layers/2.geojson) 

```
{
	"id": 2,
	"type": "Feature",
	"properties": {
		"name": "Category:Maps Of Tartu",
		"description": null,
		"created_at": "2015-11-12T10:56:25.461Z",
		"bbox": "26.111586,58.232919,27.358788,58.486400",
		"maps_count": 2,
		"rectified_maps_count": 1,
		"rectified_percent": 50.0,
		"source_uri": "https://commons.wikimedia.org/wiki/Category:Maps Of Tartu"
	},
	"geometry": {
		"type": "Polygon",
		"coordinates": "[[[26.111586, 58.232919], [27.358788, 58.232919], [27.358788, 58.4864], [26.111586, 58.4864], [26.111586, 58.232919]]]"
	}
}
```

###Get a Map's Layers

| Method       | Definition | 
| ------------ | ---------  | 
| GET          |  /api/v1/maps/{:map_id}/layers or |
|              |  /api/v1/layers?map_id={:map_id} |

Queries and returns a list of layers that a given map belongs to.

**Parameters**

| Name       |             | Type    | Description                                                             | Required | Notes                                             |
|------------|-------------|---------|-------------------------------------------------------------------------|----------|---------------------------------------------------|
| map_id     |             | integer | the unique identifier for a map                                         | required |                                                   |
| query      |             | string  | search query                                                            | optional |                                                   |
| field      |             | string  | specified field to be searched                                          | optional | default is title                                  |
|            | name        | string  | the title of the layer                                                  | optional | default                                           |
|            | description | string  | the description of the layer                                            | optional |                                                   |
| sort_key   |             |         | the field that should be used to sort the results                       | optional | default is updated_at                             |
|            | name        | string  | the name of the layer                                                   | optional |                                                   |
|            | updated_at  | string  | when the layer was last updated                                         | optional | default                                           |
|            | created_at  | string  | when the layer was created                                              | optional |                                                   |
|            | percent     | string  | the percent of maps which are rectified in the layer                    | optional | ordered by integer (see below)                    |
| sort_order |             | string  | the order in which the results should appear                            | optional | default is desc                                   |
|            | asc         |         | ascending order                                                         | optional |                                                   |
|            | desc        |         | descending order                                                        | optional | default                                           |
| format     |             | string  | specifies output format                                                 | optional | can also be passed in as extension, eg. maps.json |
|            | json        | string  | JSON format for layer                                                   | optional | default                                           |
|            | geojson     | string  | GeoJSON format for layer                                                | optional | simple array, not featurecollection               |
| page       |             | integer | the page number; use to get the next or previous page of search results | optional |                                                   |
| per_page   |             | integer | number of results per page                                              | optional | default is 50                                     |
| bbox	     | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited | optional |
| operation  |             | string  | specifies how to apply the bounding box  | optional  | default is intersect |
|            | intersect   | string  |uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter  | optional | preferred; orders results by proximity to the bbox extent; default |
|            | within      | string	 | uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter  | optional      |  |

**Request Example** 

[http://mapwarper.net/api/v1/maps/3/layers?query=tartu&sort_key=percent](http://mapwarper.net/api/v1/maps/3/layers?query=tartu&sort_key=percent)

Alternatively, the URL can be constructed by passing in the map_id as a paramter:

[http://mapwarper.net/api/v1/layers?query=tartu&sort_key=percent&map_id=3](http://mapwarper.net/api/v1/layers?query=tartu&sort_key=percent&map_id=3)

**Response**

Same response format as for listing and querying layers.
See [Query or List Layers](#query-or-list-layers) 

###Get a Layer's Maps

| Method       | Definition | 
| ------------ | -------    | 
| GET          | /api/v1/layers/{:layer_id}/maps  or |
|              | /api/v1/layers?layer_id={:layer_id} |

Returns a paginated list of the maps that comprise a given layer.

**Parameters**

| Name        | values      | Type    | Description                                                             | Required | Notes                                             |
|-------------|-------------|---------|-------------------------------------------------------------------------|----------|---------------------------------------------------|
| layer_id    |             | integer | the unique identifier for the layer                                     | required |                                                   |
| query       |             | string  | search query                                                            | optional |                                                   |
| field       |             | string  | specified field to be searched                                          | optional | default is title                                  |
|             | title       | string  | the title of the map                                                    | optional | default                                           |
|             | description | string  | the description of the map                                              | optional |                                                   |
|             | publisher   | string  | the publisher                                                           | optional |                                                   |
|             | author      | string  | the author of the map                                                   | optional |                                                   |
|             | status      | string  | the status                                                              | optional |                                                   |
| sort_key    |             |         | the field that should be used to sort the results                       | optional | default is updated_at                             |
|             | title       | string  | the title of the map                                                    | optional |                                                   |
|             | updated_at  | string  | when the map was last updated                                           | optional | default                                           |
|             | created_at  | string  | when the map was created                                                | optional |                                                   |
|             | status      | string  | the status of the map                                                   | optional | ordered by integer (see below)                    |
| sort_order  |             | string  | the order in which the results should appear                            | optional | default is desc                                   |
|             | asc         |         | ascending order                                                         | optional |                                                   |
|             | desc        |         | descending order                                                        | optional | default                                           |
| show_warped |             | integer | limits to maps that have already been warped                            | optional |                                                   |
|             | 1           | integer | limits to maps that have already been warped                            | optional |                                                   |
|             | 0           | integer | gets all maps, warped and unwarped                                      | optional | default                                           |
| format      |             | string  | specifies output format                                                 | optional | can also be passed in as extension, eg. maps.json |
|             | json        | string  | JSON format for maps                                                    | optional | default                                           |
|             | geojson     | string  | GeoJSON format for maps                                                 | optional | simple array, not featurecollection               |
| page        |             | integer | the page number; use to get the next or previous page of search results | optional |                                                   |
| per_page    |             | integer | number of results per page                                              | optional | default is 50                                     |
| bbox	      | a comma-separated string of latitude and longitude coordinates | a rectangle delineating the geographic area to which the search should be limited | optional |
| operation   |           | string       | specifies how to apply the bounding box  | optional  | default is intersect |
|             | intersect | string       |uses the PostGIS ST_Intersects operation to retrieve warped maps whose extents intersect with the bbox parameter  | optional | preferred; orders results by proximity to the bbox extent; default |
|             | within    | string	      | uses a PostGIS ST_Within operation to retrieve warped maps that fall entirely within the extent of the bbox parameter  | optional      |  |

**Request Examples**
 
[http://mapwarper.net/api/v1/layers/3/maps](http://mapwarper.net/api/v1/layers/3/maps) or

[http://mapwarper.net/api/v1/layers?layer_id=3](http://mapwarper.net/api/v1/layers?layer_id=3)

**Response**

Same response as for listing and querying layers.

See [Search for Maps](#search-for-maps) 


###Map and Layer Web Map Services

The WMS and Tile services are available and are now shown in the standard JSON responses

------------------------------


##Ground Control Points

Ground control points are the user-selected locations used to warp an image.

###List and Sort Control Points

| Method        | Definition    |
| ------------- | ------------- |
| GET           |  /api/v1/gcps  |

Gets and sorts all control points.
No authentication required.

**Parameters**

| Name       | values     | Type    | Description                                                             | Required | Notes                 |
|------------|------------|---------|-------------------------------------------------------------------------|----------|-----------------------|
| sort_key   |            |         | the field that should be used to sort the results                       | optional | default is updated_at |
|            | map_id     | string  | the id of the map the GCP belongs to                                    | optional |                       |
|            | lat        | string  | the latitude of the ground control point                                | optional |                       |
|            | lon        | string  | the longitude of the ground control point                               | optional |                       |
|            | x          | string  | the x coordinate on the image that corresponds to "lon"                 | optional |                       |
|            | y          | string  | the y coordinate on the image that corresponds to "lat"                 | optional |                       |
|            | updated_at | string  | when the GCP was last updated                                           | optional | default               |
|            | created_at | string  | when the GCP was first created                                          | optional |                       |
| sort_order |            | string  | the order in which the results should appear                            | optional | default is desc       |
|            | asc        |         | ascending order                                                         | optional |                       |
|            | desc       |         | descending order                                                        | optional | default               |
| page       |            | integer | the page number; use to get the next or previous page of search results | optional |                       |
| per_page   |            | integer | number of results per page                                              | optional | default is 50         |
| map_id     |            | integer | restricts results to the map given                                      | optional |                       |

**Request Examples**
 
[http://mapwarper.net/api/v1/gcps?per_page=2&sort_key=updated_at](http://mapwarper.net/api/v1/gcps?per_page=2&sort_key=updated_at) 


**Response**

```
{
	"data": [
		{
			"id": "2",
			"type": "gcps",
			"attributes": {
				"map_id": 2,
				"x": 151.833333333328,
				"y": 392.666666666666,
				"lat": "52.7603488553",
				"lon": "-4.6579885155",
				"created_at": "2015-10-23T12:38:29.023Z",
				"updated_at": "2016-06-08T10:54:44.094Z",
				"error": null
			}
		},
		{
			"id": "3",
			"type": "gcps",
			"attributes": {
				"map_id": 2,
				"x": 72.2142857142853,
				"y": 712.952380952381,
				"lat": "49.8494421783",
				"lon": "-5.2512502342",
				"created_at": "2015-10-23T12:38:36.048Z",
				"updated_at": "2016-06-08T10:54:34.903Z",
				"error": null
			}
		}
	],
	"links": {
		"self": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=1&page%5Bsize%5D=2&per_page=2&sort_key=updated_at",
		"next": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=2&page%5Bsize%5D=2&per_page=2&sort_key=updated_at",
		"last": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=7&page%5Bsize%5D=2&per_page=2&sort_key=updated_at"
	},
	"meta": {
		"total_entries": 13,
		"total_pages": 7
	}
}
```
**Response Elements**


***Data***

An array of control points, each having an attributes object and, id and type and links

| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the gcp             |       |  
| type          |    gcps       | the type of resource            |      |  
| links         |               | links to the resource, and export links |   |   
| attributes    |               | Attributes of the gcps | see separate table for more detail   |  


***Links***

The top level links holds pagination links. Shown if there are more results than are contained in the response.

```
"links": {
		"self": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=1&page%5Bsize%5D=2&per_page=2&sort_key=updated_at",
		"next": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=2&page%5Bsize%5D=2&per_page=2&sort_key=updated_at",
		"last": "http://mapwarper.net/api/v1/gcps?page%5Bnumber%5D=7&page%5Bsize%5D=2&per_page=2&sort_key=updated_at"
},
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps, Shown if there are more results than are contained in the response.

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```
indicates that 50 results have been found over 2 pages.

| Value | Description |
| ------| -------     |
| total_entries | the total number of layers found for this request |
| total_pages |  the total number of pages found |


***Attributes***

| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| map_id         | id      | the unique identifier for the map the point belongs to   |  see below for other way to get gcps for a map |
| lat           | big decimal | the latitude of the ground control point   | |
| lon           | big decimal | the longitude of the ground control point           | |
| x             | float       | the x coordinate on the image that corresponds to "lon"   | |
| y             | float       | the y coordinate on the image that corresponds to "lat"   | |
| error         | float       | the calculated root mean square error, or distortion, for the ground control point   | null unless called via `/api/v1/maps/{:map_id}/gcps` see below |
| created_at    | date, time, & time zone | the date and time when the ground control point was created   | |
| updated_at    | date, time, & time zone | the date and time when the ground control point was last updated   | |


###Get a Map's Ground Control Points

There are two different ways to get the control points of a map:

| Method        | Definition    |
| ------------- | ------------- |
| GET           |  /api/v1/maps/{:map_id}/gcps    or  | 
|               |  /api/v1/gcps?map_id={:map_id}  (see above) |

Returns a list of the ground control points used to warp a map, as well as their calculated errors.
No authentication required. 

> ** Note: api/v1/maps/:id/gcps includes the calculated error but with no sorting or pagination, whereas api/v1/gcps?map_id={:map_id} whilst has sorting and pagination but with no calculated error.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes     |
| ------------- | ----------  | ----------  | ----------  | --------  | --------- |
| map_id        |             | integer     | the unique identifier for the map   |  required         |       |


**Request Examples**

[http://mapwarper.net/api/v1/maps/2/gcps](http://mapwarper.net/api/v1/maps/2/gcps) 

**Response**

The response will be a list of ground control points in the following format.

```
{
	"data": [
		{
			"id": "1",
			"type": "gcps",
			"attributes": {
				"map_id": 2,
				"x": 479.35714285714,
				"y": 380,
				"lat": "52.959343811",
				"lon": "0.593476328",
				"created_at": "2015-10-23T12:38:24.222Z",
				"updated_at": "2015-10-23T12:38:24.222Z",
				"error": 13.781432496303088
			}
		},
		...snip...
		{
			"id": "19",
			"type": "gcps",
			"attributes": {
				"map_id": 2,
				"x": 110.21428571429,
				"y": 119.42857142857,
				"lat": "54.9945666448",
				"lon": "-5.1378768477",
				"created_at": "2016-06-08T10:54:28.391Z",
				"updated_at": "2016-06-08T10:54:28.391Z",
				"error": 15.401820748382049
			}
		}
	],
	"meta": {
		"map-error": 17.280250155403902
	}
}
```
**Response Elements**


***Data***

An array of control points, each having an attributes object and, id and type and links

| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the gcp             |       |  
| type          |    gcps       | the type of resource            |      |   
| attributes    |               | Attributes of the gcps | see separate table for more detail   |  

***Meta***

Contains details about the combined error for the control points for the entire map

```
	"meta": {
		"map-error": 17.280250155403902
	}
```

***Attributes***


| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| map_id         | id      | the unique identifier for the map the point belongs to   |   |
| lat           | big decimal | the latitude of the ground control point   | |
| lon           | big decimal | the longitude of the ground control point           | |
| x             | float       | the x coordinate on the image that corresponds to "lon"   | |
| y             | float       | the y coordinate on the image that corresponds to "lat"   | |
| error         | float       | the calculated root mean square error, or distortion, for the ground control point   |  |
| created_at    | date, time, & time zone | the date and time when the ground control point was created   | |
| updated_at    | date, time, & time zone | the date and time when the ground control point was last updated   | |



###Get a Single Ground Control Point

| Method       | Definition | 
| ------------ | ---------- | 
| GET          |  /api/v1/gcps/{:gcp_id} |

Returns a specified ground control point by ID.
No authentication required.

**Parameters**

| Name          |             | Type        | Description | Required  | Notes     |
| ------------- | ----------  | ----------  | ----------  | --------  | --------- |
| gcp_id        |             | integer     | the unique identifier for the ground control point   |  required  |       |


**Example**

[http://mapwarper.net/api/v1/gcps/2](http://mapwarper.net/api/v1/gcps/2)

**Response**

```
{
	"data": {
		"id": "2",
		"type": "gcps",
		"attributes": {
			"map_id": 2,
			"x": 151.833333333328,
			"y": 392.666666666666,
			"lat": "52.7603488553",
			"lon": "-4.6579885155",
			"created_at": "2015-10-23T12:38:29.023Z",
			"updated_at": "2016-06-08T10:54:44.094Z",
			"error": null
		}
	}
}
```

**Response Elements**

***Data***

| Name          |    Value	   | Description                    	| Notes |  
| ------| -------     |------| -------     |
| id            |               | The id for the gcp             |       |  
| type          |    gcps       | the type of resource            |      |   
| attributes    |               | Attributes of the gcps | see separate table for more detail   |  

***Attributes***


| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| map_id         | id      | the unique identifier for the map the point belongs to   |   |
| lat           | big decimal | the latitude of the ground control point   | |
| lon           | big decimal | the longitude of the ground control point           | |
| x             | float       | the x coordinate on the image that corresponds to "lon"   | |
| y             | float       | the y coordinate on the image that corresponds to "lat"   | |
| error         | float       | the calculated root mean square error, or distortion, for the ground control point   |  |
| created_at    | date, time, & time zone | the date and time when the ground control point was created   | |
| updated_at    | date, time, & time zone | the date and time when the ground control point was last updated   | |



If the GCP is not found, the request will return the following response:

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"errors":[{"title":"Not found","detail":"Couldn't find Gcp with 'id'=2222"}]}```    |

###Add Ground Control Point

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  /api/v1/gcps |

Adds the ground control points on which a warp will be based, passing in JSON-API for the GCP.
Requires authentication.

**Parameters**

The body of the request should be in JSON-API format with the following attributes:

| Name               | Type        | Description           	| Notes |  
| ------| -------     |------| -------     |
| lat           | big decimal | the latitude of the ground control point   |required |
| lon           | big decimal | the longitude of the ground control point           | required|
| x             | float       | the x coordinate on the image that corresponds to "lon"   | required|
| y             | float       | the y coordinate on the image that corresponds to "lat"   | required|


Example:

```
{
	"data": {
		"type": "gcps",
		"attributes": {
			"map_id": 2,
			"x": 2,
			"y":3,
			"lat": "52.56",
			"lon": "-4.65"
		}
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X POST -d '{"data":{"type":"gcps","attributes":{"x":1,"y":2,"lat":33.3,"lon":44.4,"map_id":2}}}' http://mapwarper.net/api/v1/gcps -b cookie
```

**Response**

If successful, the response should return the created point:

```
{
	"data": {
		"id": "21",
		"type": "gcps",
		"attributes": {
			"map_id": 2,
			"x": 1.0,
			"y": 2.0,
			"lat": "33.3",
			"lon": "44.4",
			"created_at": "2016-06-10T13:50:34.193Z",
			"updated_at": "2016-06-10T13:50:34.193Z",
			"error": null
		}
	}
}
```

An error will return something similar to the following message.

```
{
	"errors": [{
		"source": {
			"pointer": "/data/attributes/x"
		},
		"detail": "is not a number"
	}, {
		"source": {
			"pointer": "/data/attributes/x"
		},
		"detail": "can't be blank"
	}]
}
```

###Update a GCP

| Method       | Definition | 
| ------------ | -------    | 
| PATCH          |  /api/v1/gcps/{:gcp_id} |

Updates a given GCP.
Requires authentication.

**Attributes**

| Name          |             | Type        | Description | Required  | Notes |
| ------------- | ----------  | ----------  | ----------- | --------- | ----- |
| map_id        |             | integer     | the unique identifier of the map the point belongs to | optional |   |
| lat           |             | big decimal | the latitude of the ground control point to warp to    | optional  |  |
| lon           |             | big decimal | the longitude of the ground control point to warp to   | optional  |  |
| x             |             | float       | the x coordinate on the unwarped image that corresponds to "lon"    | optional | |
| y             |             | float       | the y coordinate on the unwarped image that corresponds to "lat"    | optional |  | 


**Example using cURL and cookie authentication**

In this example, we are changing the value of x and y.

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PUT -d '{"data":{"type":"gcps","attributes":{"x":22,"y":55,"map_id":2}}}' http://mapwarper.net/api/v1/gcps/21 -b cookie
```

**Response**

If successful the response will be the updated control point.

Example:

```
{
	"data": {
		"id": "21",
		"type": "gcps",
		"attributes": {
			"map_id": 2,
			"x": 22.0,
			"y": 55.0,
			"lat": "33.3",
			"lon": "44.4",
			"created_at": "2016-06-10T13:50:34.193Z",
			"updated_at": "2016-06-10T14:59:56.596Z",
			"error": null
		}
	}
}
```

###Delete a GCP

| Method        | Definition | 
| ------------- | ---------  | 
| DELETE        |  /api/v1/gcp/{:gcp_id} |

Deletes a ground control point. 
Requires authentication.

**Parameters**

| Name        | Type        | Description | Required  | 
| ----------- | ---------   | ---------   | --------- |
| gcp_id      |  integer    | the unique identifier for the ground control point  |  required |

Example: 

**curl example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X DELETE http://mapwarper.net/api/v1/gcps/21 -b cookie
```

**Response**

If deleted, it will return with the deleted point.

If the GCP is not found, the request will return the following response:

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"errors":[{"title":"Not found","detail":"Couldn't find Gcp with 'id'=2222"}]}```    |



##Masking

Uses GML to mask a portion of the map. This essentially crops the map. Masking is used to delete the borders around the map images to make a seamless layer of contiguous maps. 

###Get Mask

| Method        | Definition | 
| ------------- | ---------  | 
| GET           |  http://mapwarper.net/mapimages/{:map_id}.gml.ol |

Gets a GML string containing coordinates for the polygon(s) to mask over.
No authentication required. 

> ** Note: The correct way to find the path to the mask is to get the Map object and look in it's links

```
"mask": "http://mapwarper.net/mapimages/260.gml.ol",
```

**Examples**

http://mapwarper.net/shared/masks/7449.gml.ol 

**Response Example**

```
{{{
<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1474.9689999999998,5425.602 3365.091,5357.612 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4493.725,1917.318 4072.187,1645.358 3079.533,1441.388 2467.623,1427.79 2304.447,1264.614 1529.3609999999999,1332.6039999999998 1542.9589999999998,1862.926 2005.291,2202.876 1624.547,2542.826 </nowiki><nowiki>1651.743,3195.53 1665.341,3698.656 1692.5369999999998,3997.812 2005.291,4201.782 2005.291,4419.35 1570.155,5140.044 1474.9689999999998,5425.602</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_201"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1447.773,4854.486 1828.5169999999998,4582.526 1950.899,4242.576 1774.125,4065.802 1583.753,3902.626 1610.949,3345.108 1597.3509999999999,2923.57 1447.773,2638.0119999999997 1379.783,2787.59 1338.989,4854.486 1447.773,4854.486</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>
}}}
```

###Save Mask

| Method        | Definition | 
| ------------- | -------    | 
| POST          | /api/v1/maps/:id/mask  |

Saves a mask. Returns map json.
Requires authentication.

**Parameters**

| Name          |              | Type        | Description  | Required  | Notes |
| ------------- | ---------    | ----------  | ---------    | --------  | ----- |
| map_id        |              |  integer    | the unique indentifer for the map | required  | |
| output        |              |  gml        | the GML      | required  |        |

**cURL Example**

```
{{{
curl -X POST -d "format=json" -d 'output=<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>' http://mapwarper.net/api/v1/maps/2/mask -b cookie
}}}
```

**Response**

A successful call will return the applicable map in json-api format.




###Delete Mask

| Method        | Definition | 
| ------------- | -------    | 
| DELETE        |  /api/v1/maps/{:map_id}/mask |

Deletes a mask.
Requires authentication.

**Parameters** 

| Name          |             | Type        | Description | Required  | 
| ------------- | ---------   | ---------   | ----------- | --------  |
| map_id        |             | integer     | the unique identifier for the map   |  required  |


**Response**

If sucessfully deleted the response will be the affected map in json api format


###Crop / Mask Map

| Method        | Definition | 
| ------------- | -------    | 
| PATCH          |  /api/v1/maps/{:map_id}/crop |

Applies the clipping mask to a map, but does not warp it. A clipping mask should be saved before calling this. Requires authentication.

**Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH http://mapwarper.net/api/v1/maps/2/crop -b cookie
```

**Response**

If successul, returns the target map in json

**Errors**

If there is no mask saved, the following error will be returned (Error Status 422)

```
{
	"errors": [{
		"title": "Mask error",
		"detail": "Mask file not found"
	}]
}
```


###Save, Mask, and Warp Map

| Method       | Definition | 
| ------------ | --------   | 
| PATCH         |  /api/v1/maps/:map_id/mask_crop_rectify |

Rolls the calls into one. Saves the mask, applies the mask to the map, and warps the map using the mask. 
Requires authentication.

**Parameters**

| Name        | Type        | Description | Required  |
| ----------- | ----------- | ----------  | --------- |
| map_id      | integer     | the unique identifier for the map | required |
| output        |              |  gml        | the GML      | required  |        |


**Example**

```
{{{
curl -X POST -d "format=json" -d 'output=<wfs:FeatureCollection xmlns:wfs="http://www.opengis.net/wfs"><gml:featureMember xmlns:gml="http://www.opengis.net/gml"><feature:features xmlns:feature="http://mapserver.gis.umn.edu/mapserver" fid="OpenLayers.Feature.Vector_207"><feature:geometry><gml:Polygon><gml:outerBoundaryIs><gml:LinearRing><gml:coordinates decimal="." cs="," ts=" ">1490.0376070686068,5380.396178794179 3342.4880893970894,5380.214910602912 3582.659,5126.446 3555.463,4813.692 3637.051,4487.34 4276.157,3753.048 4575.313,3113.942 4546.465124740124,1412.519663201663 2417.4615530145525,1317.354124740125 1431.415054054054,1294.9324823284824 1447.7525384615387,2187.807392931393 1434.5375363825372,5034.563750519751 1490.0376070686068,5380.396178794179</gml:coordinates></gml:LinearRing></gml:outerBoundaryIs></gml:Polygon></feature:geometry></feature:features></gml:featureMember></wfs:FeatureCollection>' http://mapwarper.net/api/v1/maps/2/mask_crop_rectify -b cookie
}}}
```

**Response**

As rectify call.

--------

##Warping

| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/maps/{:map_id}/rectify |

Warps or rectifies a map according to its saved GCPs and the parameters passed in. 
Requires authentication.

**Curl Example**

```
curl -X PATCH -d "use_mask=false&format=json" -u email@example.com:password  http://mapwarper.net/api/v1/maps/7449/rectify
```

**Parameters**

| Name     |      | Type    | Description                                             | Required | Notes            |
|----------|------|---------|---------------------------------------------------------|----------|------------------|
| map_id   |      | integer | the unique identifier for the map                       | required |                  |
| use_mask |      | boolean | applies any saved mask to the map                       | optional | default is false |
| format   |      | string  | specifies output format                                 | optional | default is HTML  |
|          | json |         | requests output in JSON format, rather than HTML or XML | optional |                  |

**Other Parameters**

The following options specify the algorithm or method that should be used to warp a map.

| Name              |             | Type   | Description            | Required | Notes                                 |
|-------------------|-------------|--------|------------------------|----------|---------------------------------------|
| resample_options  |             | string |                        | optional |                                       |
|                   | near        |        | nearest neighbor       | optional | fastest processing; default           |
|                   | bilinear    |        | bilinear interpolation | optional |                                       |
|                   | cubic       |        | cubic                  | optional | good option, but slower               |
|                   | cubicspline |        | cubic spline           | optional | slowest; best quality                 |
| transform_options |             | string |                        | optional |                                       |
|                   | auto        |        |                        | optional | default                               |
|                   | p1          |        | 1st order polynomial   | optional | requires a minimum of 3 GCPs          |
|                   | p2          |        | 2nd order polynomial   | optional | requires a minimum of 6 GCPs          |
|                   | p3          |        | 3rd order polynomial   | optional | requires a minimum of 10 GCPs         |
|                   | tps         |        | thin plate spline      | optional | requires many evenly-distributed GCPs |

**Response**

If successful the response will the target map in json format

If there is an error, a 422 status code is sent along with json

**Errors**

Two common error messages are:

Not enough Ground Control Points
```
{
	"errors": [{
		"title": "Not enough gcps",
		"detail": "Map needs at least 3 control points to rectify."
	}]
}
```

Map currently being rectified
```
{
	"errors": [{
		"title": "Map busy",
		"detail": "Map currently being rectified. Try again later."
	}]
}
```

--------

##Create Map

| Method       | Definition | 
| ------------ | -------    | 
| POST         |  /api/v1/maps |

Creates a new map.
Requires authentication.

**Parameters**

The body of the request should be in JSON-API format with the following attribute. 

| Name    | Type    | Description                | Notes                                                 |
|---------|---------|----------------------------|-------------------------------------------------------|                                       |
| title   | string  | the title of the map       | required, but will be overwritten from wiki page      | 

The PAGEID is the unique number given to all mediawiki pages. 

Example:

```
{
	"data": {
		"type": "maps",
		"attributes": {
      "title": "initial title"
		}
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json'  -X POST -d '{"data":{"type":"maps","attributes": {"title":"initial title"}}}' http://mapwarper.net/api/v1/maps -b cookie
```

**Response**

If successful, the response should return the created map in json format

***Errors***

Status 422 and message for example if the page_id is not a number:

```
{
	"errors": [{
		"source": {
			"pointer": "/data/attributes/page_id"
		},
		"detail": "is not a number"
	}]
}
```

##Update Map


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/maps/{:id} |
 
Updates a  map. Allows an editor to change title and description.
Requires authentication.
Editor role only authorized. 

**Parameters**


| Name      	  |  Type      | Description  |  Required | 
| ------------- | ---------- | ------------ |  -------- | 
|   id     		  | integer    | the unique identifier for the map   | required |


The body of the request should be in JSON-API format with the following attributes 

| Name        | Type | Description | Notes                      |          |
|-------------|------|-------------|----------------------------|----------|
| title       |      | string      | the title of the map       | optional |
| description |      | string      | the description of the map | optional |

Example:

```
{
	"data": {
		"type": "maps",
		"attributes": {
      "title": "New Improved title",
      "description": "A better reading description"
		}
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH -d '{"data":{"type":"maps","attributes": {"title":"A New Improved Title"}}}' http://mapwarper.net/api/v1/maps/3 -b cookie
```

**Response**

If successful, the response should return the created map in json format

***Errors***

Status 422 and message with errors.


##Destroy Map

| Method       | Definition | 
| ------------ | -------    | 
| DELETE         |  /api/v1/maps/{:id} |
 
Deletes a map. Allows an editor to delete a specific map.
Requires authentication.
Editor role only authorized. 

**Parameters**


| Name      	    |  Type      | Description  |  Required | 
| -------------  | ---------- | ------------ |  -------- | 
|   id     		  | integer    | the unique identifier for the map   | required |




**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X DELETE http://mapwarper.net/api/v1/maps/3 -b cookie
```

**Response**

If successful, the response should return the created map in json format

***Errors***

Status 422 and message with errors.

##Publish Map

Publishes a map. This stops the map from being edited further. Maps should be warped before publishing.
Authentication required.
Administrator role authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/maps/{:id}/publish |
 

**Parameters**


| Name      	    |  Type      | Description  |  Required | 
| -------------  | ---------- | ------------ |  -------- | 
|   id     		  | integer    | the unique identifier for the map   | required |


**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH  http://mapwarper.net/api/v1/maps/3/publish -b cookie
```

**Response**

If successful, the response should return the created map in json format

***Errors***

Status 422 and message with errors.

If map is not warped:
```
{
	"errors": [{
		"title": "Map not warped",
		"detail": "Map is not warped so cannot be published"
	}]
}
```

Other error

```
{
	"errors": [{
		"title": "Publish error",
		"detail": "Error with publishing map"
	}]
}
```

##Unpublish Map

Unpublishes a map. This allows the map to be edited. Maps should be published before unpublishing.
Authentication required.
Administrator role authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/maps/{:id}/unpublish |
 

**Parameters**


| Name      	    |  Type      | Description  |  Required | 
| -------------  | ---------- | ------------ |  -------- | 
|   id     		  | integer    | the unique identifier for the map   | required |


**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH  http://mapwarper.net/api/v1/maps/3/unpublish -b cookie
```

**Response**

If successful, the response should return the created map in json format

***Errors***

Status 422 and message with errors.

If map is not published:
```
{
	"errors": [{
		"title": "Publish error",
		"detail": "Map is not published so cannot be unpublished"
	}]
}
```

Other error

```
{
	"errors": [{
		"title": "Publish error",
		"detail": "Error with unpublishing map"
	}]
}
```

##Add Many GCPs

Adds many Ground Control Point at once to one or more maps
Authentication required.
Editor role authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| POST         |  /api/v1/gcps/add_many  |
 

**Parameters**


| Name      	    |  Type      | Description  |  Required | 
| -------------   | ---------- | ------------ |  -------- | 
|   gcps     		  | array      | an array of control points   | required |

Each gcp should have a ```mapid```  attribute to be able to add the control point to the correct map.
Points cannot be added twice. 

```
{
	"gcps": [{
		"mapid": 123,
		"x": 2,
		"y": 3,
		"lat": "52.56",
		"lon": "-4.65"
	}, {
		"mapid": 123,
		"x": 12,
		"y": 23,
		"lat": "32.56",
		"lon": "-2.65"
	}]
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X POST -d '{"gcps":[{"mapid":123,"x":2,"y":3,"lat":"52.56","lon":"-4.65"},{"mapid":123,"x":12,"y":23,"lat":"32.56","lon":"-2.65"}]}' http://mapwarper.net/api/v1/gcps/add_many -b cookie
```

**Response**

If successful, the response should return the newly added gcps

```
{
  "data": [
    {
      "id": "228",
      "type": "gcps",
      "attributes": {
        "map_id": 123,
        "x": 2.0,
        "y": 3.0,
        "lat": "52.56",
        "lon": "-4.65",
        "created_at": "2016-06-11T16:29:32.948Z",
        "updated_at": "2016-06-11T16:29:32.948Z",
        "error": null
      }
    },
    {
      "id": "228",
      "type": "gcps",
      "attributes": {
        "map_id": 542,
        "x": 2.0,
        "y": 3.0,
        "lat": "52.56",
        "lon": "-4.65",
        "created_at": "2016-06-11T16:29:32.948Z",
        "updated_at": "2016-06-11T16:29:32.948Z",
        "error": null
      }
    }
  ]
}
```

***Errors***

If a map cannot be found

```
{"errors":[{"title":"Not found","detail":"Couldn't find Map with 'id'=123"}]}
```



##Create Layer

Creates a new layer and adding several existing maps to it at the same time.
Authentication required.
Administrator authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| POST         |  /api/v1/layers |
 

**Parameters**

The body of the request should be in JSON-API format. ```data``` may also have ```map_ids``  - an array of existing map ids to add to the layer.

| Name       |             | Type   | Description                          | Notes    |
|------------|-------------|--------|--------------------------------------|----------|
| data       |             |        |                                      |          |
|            | type        | string | "layers"                             | required |
|            | map_ids     | array  | array of integers of the maps to add | optional |
| attributes |             |        |                                      |          |
|            | name        | string | the name of the layer                | required |
|            | description | string | the description of the layer         | optional |


Example:

```
{
	"data": {
		"type": "layers",
		"attributes": {
			"name": "a new layer",
			"description": "new description"
		},
    "map_ids":[123,553,224]
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X POST -d '{"data":{"type":"layers","attributes":{"name":"a new layer","description":"new description"},"map_ids":[123,553,224]}}' http://mapwarper.net/api/v1/layers -b cookie
```

**Response**

If successful, the response should return the new layer in json api format


##Update Layer

Updates a new layer and adding several existing maps to it at the same time. This could be used to add many maps at the same time to a layer.
Authentication required.
Administrator authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/layers/{:id} |
 

**Parameters**

| Name |   | Type    | Description                         | Required | Notes |   |
|------|---|---------|-------------------------------------|----------|-------|---|
| id   |   | integer | the unique identifier for the layer | required |       |   |

The body of the request should be in JSON-API format. ```data``` may also have ```map_ids``  - an array of existing map ids to add to the layer.

| Name       |             | Type   | Description                          | Notes    |
|------------|-------------|--------|--------------------------------------|----------|
| data       |             |        |                                      |          |
|            | type        | string | "layers"                             | required |
|            | map_ids     | array  | array of integers of the maps to add | optional |
| attributes |             |        |                                      |          |
|            | name        | string | the name of the layer                | optional |
|            | description | string | the description of the layer         | optional |


Example:

```
{
	"data": {
		"type": "layers",
		"attributes": {
			"name": "a different name"
		},
    "map_ids":[4423,22]
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH -d '{"data":{"type":"layers","attributes":{"name":"a different name"},"map_ids":[4423,22]}}' http://mapwarper.net/api/v1/layers -b cookie
```

**Response**

If successful, the response should return the updated layer in json api format

##Destroy Layer

Destroys a layer.
Authentication required.
Administrator authorized only.

| Method       | Definition          | 
|--------------|---------------------|
| DELETE       | /api/v1/layers{:id} |

**Parameters**

| Name |   | Type    | Description                         | Required | Notes |   |
|------|---|---------|-------------------------------------|----------|-------|---|
| id   |   | integer | the unique identifier for the layer | required |       |   |


**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X DELETE -d http://mapwarper.net/api/v1/layers/12 -b cookie
```

**Response**

If successful, the response should return the deleted layer in json api format


##Toggle Layer Visibility

Toggles the visibility of a layer. This turns off the layer from being mosaiced together, and having WMS and Tile export options.
It is useful for layers which represent meta groups of maps, or layers of layers. 
Authentication required.
Administrator authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/layers/{:id}/toggle_visibility |
 

**Parameters**

| Name |   | Type    | Description                         | Required | Notes |   |
|------|---|---------|-------------------------------------|----------|-------|---|
| id   |   | integer | the unique identifier for the layer | required |       |   |



**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH  http://mapwarper.net/api/v1/layers/2/toggle_visibility -b cookie
```

**Response**

If successful, the response should return the layer in json api format (with the visibility attribute).


##Remove Map From Layer

Removes a single map from a layer.
Authentication required.
Administrator authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/layers/{:id}/remove_map |
 

**Parameters**

It takes a single parameter, map_id containing the id of the map to be removed.

| Name |   | Type    | Description                         | Required | Notes |   |
|------|---|---------|-------------------------------------|----------|-------|---|
| id   |   | integer | the unique identifier for the layer | required |       |   |
| map_id     |             |  integer |   unique id of the map to be removed        |     required     |



**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH -d '{"map_id":123}' http://mapwarper.net/api/v1/layers/2/remove_map -b cookie
```

**Response**

If successful, the response should return the updated layer in json api format

If error, the following will be returned (with 422 status)

```
{
	"errors": [{
		"title": "Layer error",
		"detail": "Error removing map."
	}]
}
```


##Merge Layers

Merges the maps of two layers together. The destination layer gets the maps from the original layer. The original layer is not deleted.
Authentication required.
Administrator authorized only.


| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/layers/{:id}/remove_map |
 

**Parameters**

| Name    |   | Type    | Description                         | Required | Notes | 
|---------|---|---------|-------------------------------------|----------|-------|
| id      |   | integer | the unique identifier for the layer to be merged | required |       |  
| dest_id |   | integer | the unique identifier for the destination layer | required |       | 


**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X PATCH -d '{"dest_id":3}' http://mapwarper.net/api/v1/layers/2/merge -b cookie
```

**Response**

If successful, the response should return the destination layer in json format

If error, the following will be returned (with 422 status)

```
{
	"errors": [{
		"title": "Layer error",
		"detail": "Error merging layers"
	}]
}
```

##Get a User


| Method       | Definition | 
| ------------ | ---------- | 
| GET          |  /api/v1/users/{:id} |

Returns a specified user by ID.
Authentication required. 
Administrator authorized users will also see attributes for email and the roles the specified user has.

**Parameters**
| Name |   | Type    | Description                        | Required | Notes |
|------|---|---------|------------------------------------|----------|-------|
| id   |   | integer | the unique identifier for the user | required |       |


**Example**

[http://mapwarper.net/api/v1/users/3](http://mapwarper.net/api/v1/users/3)

**Response**

A response of a user with normal user authorizion 

```
{
	"data": {
		"id": "23",
		"type": "users",
		"attributes": {
			"login": "example",
			"created_at": "2013-08-26T15:37:34.619Z",
			"enabled": true,
			"provider": null
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/users/23"
		}
	}
}
```

A response of a user with admin user authorizion 

```
{
	"data": {
		"id": "23",
		"type": "users",
		"attributes": {
			"login": "example",
			"created_at": "2013-08-26T15:37:34.619Z",
			"enabled": true,
			"provider": null,
			"email": "example@example.com"
		},
		"relationships": {
			"roles": {
				"data": [
					{
						"id": "2",
						"type": "roles"
					},
					{
						"id": "4",
						"type": "roles"
					}
				]
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/users/2"
		}
	},
	"included": [
		{
			"id": "2",
			"type": "roles",
			"attributes": {
				"name": "editor"
			}
		},
		{
			"id": "4",
			"type": "roles",
			"attributes": {
				"name": "developer"
			}
		}
	]
}
```

**Response Elements**

***Data***

| Name          | Value | Description                    | Notes                                         |
|---------------|-------|--------------------------------|-----------------------------------------------|
| id            |       | The id for the user            |                                               | 
| type          | users | the type of resource           |                                               | 
| attributes    |       | Attributes of the user         | see table for more detail                     | 
| relationships |       | Showing the roles the user has | only admins can view the roles of other users | 
| included      |       | Giving more detail about role  | only admins can view the include roles        |

***Attributes***

| Name     | Type    | Description                                        | Notes                                              |
|----------|---------|----------------------------------------------------|----------------------------------------------------|
| login    | string  | the name of the user                               |                                                    |
| enabled  | boolean | whether the user is enabled or not                 |                                                    |
| provider | string  | if the user is from github, mediawiki, twitter etc |                                                    |
| email    | string  | email                                              | Only admin users can view the email of other users |  


If the user is not found, the request will return the following response:

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"errors":[{"title":"Not found","detail":"Couldn't find User with 'id'=2222"}]}```    |


##List Users

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/users |

**Parameters**

| Name       | values     | Type    | Description                                                             | Required | Notes                 |
|------------|------------|---------|-------------------------------------------------------------------------|----------|-----------------------|
| query      |            | string  | search query                                                            | optional |                       |
| field      |            | string  | specified field to be searched                                          | required | required              |
|            | login      | string  | the name of the user                                                    | optional |                       |
|            | email      | string  | the email of the user                                                   | optional |                       |
|            | provider   | string  | provider (github, mediawiki etc)                                        | optional |                       |
| sort_key   |            |         | the field that should be used to sort the results                       | optional | default is updated_at |
|            | login      | string  | the name of the user                                                    | optional |                       |
|            | email      | string  | the email of the user                                                   | optional |                       |
|            | enabled    | string  | if the user is enabled                                                  | optional |                       |
|            | provider   | string  | provider (github, mediawiki etc)                                        | optional |                       |
|            | updated_at | string  | when the user was last updated                                          | optional | default               |
|            | created_at | string  | when the user was created                                               | optional |                       |
| sort_order |            | string  | the order in which the results should appear                            | optional | default is desc       |
|            | asc        |         | ascending order                                                         | optional |                       |
|            | desc       |         | descending order                                                        | optional | default               |
| page       |            | integer | the page number; use to get the next or previous page of search results | optional |                       |
| per_page   |            | integer | number of results per page                                              | optional | default is 50         |

 

Notes: Enter optional text for the query, based on the search field chosen. The query text is case insensitive. This is a simple exact string text search.


**Request Example**

[http://mapwarper.net/api/v1/users?query=tim&field=login](http://mapwarper.net/api/v1/users?query=tim&field=login)

**Response**

```
{
	"data": [
		{
			"id": "23",
			"type": "users",
			"attributes": {
				"login": "tim",
				"created_at": "2010-08-26T15:37:34.619Z",
				"enabled": true,
				"provider": null,
				"email": "example@example.com"
			},
			"relationships": {
				"roles": {
					"data": [
						{
							"id": "2",
							"type": "roles"
						},
						{
							"id": "4",
							"type": "roles"
						}
					]
				}
			},
			"links": {
				"self": "http://mapwarper.net/api/v1/users/23"
			}
		},
		{
			"id": "11",
			"type": "users",
			"attributes": {
				"login": "TimExample",
				"created_at": "2015-04-22T18:45:04.988Z",
				"enabled": true,
				"provider": "github",
				"email": "example@example-github.com"
			},
			"relationships": {
				"roles": {
					"data": []
				}
			},
			"links": {
				"self": "http://mapwarper.net/api/v1/users/113"
			}
		}
	],
	"included": [
		{
			"id": "2",
			"type": "roles",
			"attributes": {
				"name": "editor"
			}
		},
		{
			"id": "4",
			"type": "roles",
			"attributes": {
				"name": "developer"
			}
		}
	],
	"links": {}
}
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps, Shown if there are more results than are contained in the response.

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```
indicates that 50 results have been found over 2 pages.

| Value | Description |
| ------| -------     |
| total_entries | the total number of users found for this request |
| total_pages |  the total number of pages found |


***Layer Links***

| Value | Description |
| ------| -------     |
| self  | the API link to the resourece |


***Attributes***

| Name     | Type    | Description                                        | Notes                                              |
|----------|---------|----------------------------------------------------|----------------------------------------------------|
| login    | string  | the name of the user                               |                                                    |
| enabled  | boolean | whether the user is enabled or not                 |                                                    |
| provider | string  | if the user is from github, mediawiki, twitter etc |                                                    |
| email    | string  | email                                              | Only admin users can view the email of other users |  


-------------


##Imports

*** Imports are disabled on mapwarper.net. These docs below relate to the Wikimaps Warper ***

Imports of maps can be added from a wiki Category and optionally to a mosaic/layer. First the import is created, then run.
Afterwards the maps of the import can be viewed. Deleted imports do not delete either the maps or the layer.
The Wiki Category should just contain images of maps, and these maps should have the {{Map}} template in each file page. E.g. https://commons.wikimedia.org/wiki/Category:Old_maps_of_Helsinki

All require authentication and are restricted to users with the editor role.

###Show Import

| Method       | Definition | 
| ------------ | ---------- | 
| GET          |  /api/v1/imports/{:id} |

Returns a specified import by ID.
Authentication required. 
Editor authorized users only.

**Parameters**

| Name |   | Type    | Description                        | Required | Notes |
|------|---|---------|------------------------------------|----------|-------|
| id   |   | integer | the unique identifier for the import | required |       |


**Example**

[http://mapwarper.net/api/v1/imports/3](http://mapwarper.net/api/v1/imports/3)

**Response**

Example of a finished Import

```
{
	"data": {
		"id": "87",
		"type": "imports",
		"attributes": {
			"category": "Category:Old maps of Merikarvia",
			"status": "finished",
			"save_layer": true,
			"created_at": "2015-09-29T16:34:55.057Z",
			"finished_at": "2015-09-29T16:35:02.718Z",
			"updated_at": "2015-09-29T16:35:02.824Z"
		},
		"relationships": {
			"maps": {
				"data": [
					{
						"id": "235",
						"type": "maps"
					},
					{
						"id": "234",
						"type": "maps"
					}
				]
			},
			"user": {
				"data": {
					"id": "2",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/imports/87"
		}
	}
}
```

Example of a ready Import

```
{
	"data": {
		"id": "121",
		"type": "imports",
		"attributes": {
			"category": "Category:Maps Of Tartu",
			"status": "ready",
			"save_layer": true,
			"created_at": "2016-06-12T13:54:42.170Z",
			"finished_at": null,
			"updated_at": "2016-06-12T13:54:42.170Z",
			"file_count": 2
		},
		"relationships": {
			"maps": {
				"data": []
			},
			"user": {
				"data": {
					"id": "2",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/imports/121"
		}
	}
}
```

**Response Elements**

***Data***

| Name          | Value | Description                          | Notes                               |
|---------------|-------|--------------------------------------|-------------------------------------|
| id            |       | The id for the user                  |                                     |
| type          | users | the type of resource                 |                                     |
| attributes    |       | Attributes of the user               | see table for more detail           |
| relationships |       | Showing the maps the import imported, and user that created it | maps are populated if the status is finished |
| link          |       | self link to api resource            |                                     | 

***Attributes***

| Name        | Type     | Description                                         | Notes                                            |
|-------------|----------|-----------------------------------------------------|--------------------------------------------------|
| category    | string   | The Wiki Category for the Import                    |                                                  |
| status      | string   | status of the import                                | one of: "ready", "running", "finished", "failed" |
| save_layer  | boolean  | if maps are added to a new or existing layer/mosaic |                                                  |
| finished_at | datetime | when the import was finished                        |                                                  |
| updated_at  | datetime | when the import was last updated                    |                                                  |
| created_at  | datetime | when the import for first created                   |                                                  |
| file_count  | integer  | the number of files due to be imported              |  only shown if status is "ready"                 |


If the import is not found, the request will return the following response:

| Status        | Response |
| ------------- | -------- | 
| 404	(not found) | ```{"errors":[{"title":"Not found","detail":"Couldn't find Import with 'id'=2222"}]}```    |



###List Imports

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/imports |

**Parameters**

| Name       | values      | Type    | Description                                                             | Required | Notes                 |
|------------|-------------|---------|-------------------------------------------------------------------------|----------|-----------------------|
| sort_key   |             |         | the field that should be used to sort the results                       | optional | default is updated_at |
|            | id          | string  | the id of the import                                                    | optional |                       |
|            | category    | string  | the category of the import                                              | optional |                       |
|            | user_id     | string  | the user_id of the user who creared the import                          | optional |                       |
|            | status      | string  | the status of the import                                                | optional |                       |
|            | finished_at | string  | when the import was finished                                            | optional |                       |
|            | created_at  | string  | when the user was created                                               | optional | default               |
| sort_order |             | string  | the order in which the results should appear                            | optional | default is desc       |
|            | asc         |         | ascending order                                                         | optional |                       |
|            | desc        |         | descending order                                                        | optional | default               |
| page       |             | integer | the page number; use to get the next or previous page of search results | optional |                       |
| per_page   |             | integer | number of results per page                                              | optional | default is 50         |




**Request Example**

[http://mapwarper.net/api/v1/imports?sort_key=status&per_page=10](http://mapwarper.net/api/v1/imports?sort_key=status&per_page=10)

**Response Example**

```
{
	"data": [
		{
			"id": "118",
			"type": "imports",
			"attributes": {
				"category": "Category:Tartu Maps",
				"status": "finished",
				"save_layer": true,
				"created_at": "2016-02-09T13:26:52.323Z",
				"finished_at": "2016-02-09T13:27:04.085Z",
				"updated_at": "2016-02-09T13:27:04.169Z"
			},
			"relationships": {
				"maps": {
					"data": [
						{
							"id": "260",
							"type": "maps"
						}
					]
				},
				"user": {
					"data": {
						"id": "2",
						"type": "users"
					}
				}
			},
			"links": {
				"self": "http://mapwarper.net/api/v1/imports/118"
			}
...snip...
	],
	"links": {
		"self": "http://mapwarper.net/api/v1/imports?page%5Bnumber%5D=1&page%5Bsize%5D=2&per_page=2",
		"next": "http://mapwarper.net/api/v1/imports?page%5Bnumber%5D=2&page%5Bsize%5D=2&per_page=2",
		"last": "http://mapwarper.net/api/v1/imports?page%5Bnumber%5D=12&page%5Bsize%5D=2&per_page=2"
	}
}
```

| Value | Description |
| ------| -------     |
| self | the link to the current page |
| next |  the next page in the sequence |
| last |  the last page in the sequence of pages |


###List Import Maps

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/imports/{:id}/maps |

Lists the maps that were imported. Only returns maps if the Import has "finished" status.

**Parameters**

| Name |   | Type    | Description                          | Required | Notes |   |
|------|---|---------|------------------------------------- |----------|-------|---|
| id   |   | integer | the unique identifier for the import | required |       |   |


| Name       | values      | Type    | Description                                                             | Required | Notes                 |
|------------|-------------|---------|-------------------------------------------------------------------------|----------|-----------------------|
| sort_order |             | string  | the order in which the results should appear sorted by created_at       | optional | default is desc       |
|            | asc         |         | ascending order                                                         | optional |                       |
|            | desc        |         | descending order                                                        | optional | default               |
| page       |             | integer | the page number; use to get the next or previous page of search results | optional |                       |
| per_page   |             | integer | number of results per page                                              | optional | default is 50         |



**Request Example**

[http://mapwarper.net/api/v1/imports?sort_key=status&per_page=10](http://mapwarper.net/api/v1/imports?sort_key=status&per_page=10)

**Response**

Returns a list of maps (See List maps documentation)

Response where there are no maps (Import has not run, is "ready")

```
{"data":[],"links":{}}
```

###Create Import


| Method       | Definition | 
| ------------ | -------    | 
| POST         |  /api/v1/imports |

Adds the import passing in JSON-API for the GCP.
Requires authentication.
Editor user only authorized.

**Parameters**

The body of the request should be in JSON-API format with the following attributes:

| Name        | Type     | Description                                         | Notes                                            |
|-------------|----------|-----------------------------------------------------|--------------------------------------------------|
| category    | string   | The Wiki Category for the Import                    |      required                                    |
| save_layer  | boolean  | if maps are added to a new or existing layer/mosaic |      required                                    |


Example:

```
{
	"data": {
		"type": "gcps",
		"attributes": {
      "category":"Category:Tartu Maps",
      "save_layer":true
		}
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X POST -d '{"data":{"type":"gcps","attributes":{"category":"Category:Tartu Maps","save_layer":true}}}' http://mapwarper.net/api/v1/imports -b cookie
```

**Response**

If successful, the response should return the created import with the "ready" status

```
{
	"data": {
		"id": "121",
		"type": "imports",
		"attributes": {
			"category": "Category:Maps Of Tartu",
			"status": "ready",
			"save_layer": true,
			"created_at": "2016-06-12T13:54:42.170Z",
			"finished_at": null,
			"updated_at": "2016-06-12T13:54:42.170Z",
			"file_count": 2
		},
		"relationships": {
			"maps": {
				"data": []
			},
			"user": {
				"data": {
					"id": "2",
					"type": "users"
				}
			}
		},
		"links": {
			"self": "http://mapwarper.net/api/v1/imports/121"
		}
	}
}
```



###Update Import

| Method       | Definition | 
| ------------ | -------    | 
| PATCH         |  /api/v1/imports/{:id} |

Updated the import passing in JSON-API for the GCP.
Requires authentication.
Editor user only authorized.

**Parameters**

| Name |   | Type    | Description                          | Required | Notes |   |
|------|---|---------|------------------------------------- |----------|-------|---|
| id   |   | integer | the unique identifier for the import | required |       |   |


The body of the request should be in JSON-API format with the following attributes:

| Name        | Type     | Description                                         | Notes                                            |
|-------------|----------|-----------------------------------------------------|--------------------------------------------------|
| category    | string   | The Wiki Category for the Import                    | optional                                         |
| save_layer  | boolean  | if maps are added to a new or existing layer/mosaic | optional                                         |


Example:

```
{
	"data": {
		"type": "gcps",
		"attributes": {
      "category":"Category:Tartu Maps",
      "save_layer":true
		}
	}
}
```

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json'  -X PATCH -d '{"data":{"type":"gcps","attributes":{"category":"Category:Maps of Tartu"}}}' http://mapwarper.net/api/v1/imports/12 -b cookie
```

**Response**

If successful, the response will be the updated import (see above)


###Destroy Import


| Method       | Definition | 
| ------------ | -------    | 
| DELETE         |  /api/v1/imports |

Deletes an import.
Requires authentication.
Editor user only authorized.

> ** Note: imported maps and any created mosaic / layers will not be deleted when an import is deleted.

**Parameters**

| Name |   | Type    | Description                          | Required | Notes |   |
|------|---|---------|------------------------------------- |----------|-------|---|
| id   |   | integer | the unique identifier for the import | required |       |   |


**cURL Example**

```
curl -H "Content-Type: application/json" -X DELETE  http://mapwarper.net/api/v1/imports/12 -b cookie
```

**Response**

If successful, the response will be the deleted import (see above)

---------

##Activity & Stats

Gets the activity of users actions over maps and control points, and a report on user statistics.
Requires authentication.
Most calls do not require special authorisation (except the user stats call).

###List Activity

Lists all activity across maps and control points, ordered by created_at desc
Authentication required.

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/activity |

**Parameters**

| Name     |     | Type      | Description                                                             | Required   | Notes         |  
|----------|-----|-----------|-------------------------------------------------------------------------|------------|---------------|  
| page     |     | integer   | the page number; use to get the next or previous page of search results | optional   |               |  
| per_page |     | integer   | number of results per page                                              | optional   | default is 50 |  

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X GET  http://mapwarper.net/api/v1/activity?per_page=2 -b cookie
```

**Response**

```
{
	"data": [
		{
			"id": 2158,
			"auditable_id": 228,
			"auditable_type": "Gcp",
			"user_id": 4,
			"action": "create",
			"version": 1,
			"created_at": "2016-06-11T16:29:32.951Z"
		},
		{
			"id": 2156,
			"auditable_id": 294,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "create",
			"version": 1,
			"created_at": "2016-06-10T17:20:31.175Z"
		}
	],
	"meta": {
		"total_entries": 2140,
		"total_pages": 1070
	}
}
```

**Response Elements**


***Data***

| Name           | Type     | Description                                          | Notes                                                 |
|----------------|----------|------------------------------------------------------|-------------------------------------------------------|
| id             | integer  | unique identifier of the activity                    |                                                       |
| auditable_id   | integer  | unique identifier of the item the activity refers to | e.g. Gcp or Map                                       |
| auditable_type | string   | The type ofitem the activity refers to               | e.g. Gcp or Map                                       |
| user_id        | integer  | unique identifier of the user doing the action       |                                                       |
| action         | string   | the type of action                                   | one of: "create", "update", "destroy"                 |
| version        | integer  | the version of the item                              | e.g. a created map will always be version 1 initially |
| created_at     | datetime | the time of the action                               |                                                       |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```



###List Maps Activity

Lists all activity across just maps, ordered by created_at desc
Authentication required.

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/activity/maps |

**Parameters**

| Name     |     | Type      | Description                                                             | Required   | Notes         |  
|----------|-----|-----------|-------------------------------------------------------------------------|------------|---------------|  
| page     |     | integer   | the page number; use to get the next or previous page of search results | optional   |               |  
| per_page |     | integer   | number of results per page                                              | optional   | default is 50 |  

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X GET  http://mapwarper.net/api/v1/activity/maps?per_page=2 -b cookie
```

**Response**

```
{
	"data": [
		{
			"id": 2158,
			"auditable_id": 294,
			"auditable_type": "Map",
			"user_id": 4,
			"action": "update",
			"version": 1,
			"created_at": "2016-06-11T16:29:32.951Z"
		},
		{
			"id": 2156,
			"auditable_id": 294,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "create",
			"version": 1,
			"created_at": "2016-06-10T17:20:31.175Z"
		}
	],
	"meta": {
		"total_entries": 2140,
		"total_pages": 1070
	}
}
```

```
curl -H "Content-Type: application/json" -X GET  http://mapwarper.net/api/v1/activity/maps?per_page=2 -b cookie
```

**Response Elements**


***Data***

| Name           | Type     | Description                                          | Notes                                                 |
|----------------|----------|------------------------------------------------------|-------------------------------------------------------|
| id             | integer  | unique identifier of the activity                    |                                                       |
| auditable_id   | integer  | unique identifier of the item the activity refers to | e.g. Map                                       |
| auditable_type | string   | The type ofitem the activity refers to               | e.g.  Map                                       |
| user_id        | integer  | unique identifier of the user doing the action       |                                                       |
| action         | string   | the type of action                                   | one of: "create", "update", "destroy"                 |
| version        | integer  | the version of the item                              | e.g. a created map will always be version 1 initially |
| created_at     | datetime | the time of the action                               |                                                       |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```

###List Map Activity

Lists all activity across one specified map, ordered by created_at desc
Authentication required.

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/activity/maps/{:id} |

**Parameters**

| Name     |     | Type      | Description                                                             | Required   | Notes         |  
|----------|-----|-----------|-------------------------------------------------------------------------|------------|---------------|  
| id       |     | integer   | unique identifier of the map                                            | required   |               | 
| page     |     | integer   | the page number; use to get the next or previous page of search results | optional   |               |  
| per_page |     | integer   | number of results per page                                              | optional   | default is 50 |  

**cURL Example**

```
curl -H "Content-Type: application/json" -X GET  http://mapwarper.net/api/v1/activity/maps/260?per_page=2 -b cookie
```

**Response**

```
{
	"data": [
		{
			"id": 2116,
			"auditable_id": 260,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "update",
			"version": 16,
			"created_at": "2016-04-10T17:00:36.588Z"
		},
		{
			"id": 2115,
			"auditable_id": 260,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "update",
			"version": 15,
			"created_at": "2016-04-10T17:00:31.684Z"
		}
	],
	"meta": {
		"total_entries": 16,
		"total_pages": 8
	}
}
```

**Response Elements**


***Data***

| Name           | Type     | Description                                          | Notes                                                 |
|----------------|----------|------------------------------------------------------|-------------------------------------------------------|
| id             | integer  | unique identifier of the activity                    |                                                       |
| auditable_id   | integer  | unique identifier of the item the activity refers to |                                                    |
| auditable_type | string   | The type ofitem the activity refers to               | e.g.  Map                                       |
| user_id        | integer  | unique identifier of the user doing the action       |                                                       |
| action         | string   | the type of action                                   | one of: "create", "update", "destroy"                 |
| version        | integer  | the version of the item                              | e.g. a created map will always be version 1 initially |
| created_at     | datetime | the time of the action                               |                                                       |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```


###List User Activity

Lists all activity for one user, ordered by created_at desc
Authentication required.

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/activity/users/{:id} |

**Parameters**

| Name     |     | Type      | Description                                                             | Required   | Notes         |  
|----------|-----|-----------|-------------------------------------------------------------------------|------------|---------------|  
| id       |     | integer   | unique identifier of the user                                           | required   |               | 
| page     |     | integer   | the page number; use to get the next or previous page of search results | optional   |               |  
| per_page |     | integer   | number of results per page                                              | optional   | default is 50 |  

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json' -X GET  http://mapwarper.net/api/v1/activity/users/3?per_page=2 -b cookie
```

**Response**

```
{
	"data": [
		{
			"id": 2148,
			"auditable_id": 287,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "update",
			"version": 3,
			"created_at": "2016-05-03T12:14:11.872Z"
		},
		{
			"id": 2147,
			"auditable_id": 287,
			"auditable_type": "Map",
			"user_id": 2,
			"action": "update",
			"version": 2,
			"created_at": "2016-05-03T12:14:11.607Z"
		}
	],
	"meta": {
		"total_entries": 1755,
		"total_pages": 878
	}
}
```

**Response Elements**


***Data***

| Name           | Type     | Description                                          | Notes                                                 |
|----------------|----------|------------------------------------------------------|-------------------------------------------------------|
| id             | integer  | unique identifier of the activity                    |                                                       |
| auditable_id   | integer  | unique identifier of the item the activity refers to |                                                       |
| auditable_type | string   | The type ofitem the activity refers to               |                                                       |
| user_id        | integer  | unique identifier of the user doing the action       |                                                       |
| action         | string   | the type of action                                   | one of: "create", "update", "destroy"                 |
| version        | integer  | the version of the item                              | e.g. a created map will always be version 1 initially |
| created_at     | datetime | the time of the action                               |                                                       |

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```

###User Statistics

Returns statistics of all users based on combined activity.
Authentication required.
Administrator role only authorized

| Method       | Definition | 
| ------------ | -------    | 
| GET          |  /api/v1/stats |

**Parameters**

**Parameters**

| Name       | values            | Type    | Description                                                             | Required | Notes                  |
|------------|-------------------|---------|-------------------------------------------------------------------------|----------|------------------------|
| sort_key   |                   |         | the field that should be used to sort the results                       | optional | default is total_count |
|            | total_count       |         | total  number of changes                                                |          |                        |
|            | map_count         |         | number of map changes                                                   |          |                        |
|            | gcp_count         |         | number of gcp changes                                                   |          |                        |
|            | gcp_update_count  |         | number of gcp update changes                                            |          |                        |
|            | gcp_create_count  |         | number of gcp creations                                                 |          |                        |
|            | gcp_destroy_count |         | number of gcp deletions                                                 |          |                        |
|            | user_id           |         | user id                                                                 |          |                        |
| sort_order |                   | string  | the order in which the results should appear                            | optional | default is desc        |
|            | asc               |         | ascending order                                                         | optional |                        |
|            | desc              |         | descending order                                                        | optional | default                |
| page       |                   | integer | the page number; use to get the next or previous page of search results | optional |                        |
| per_page   |                   | integer | number of results per page                                              | optional | default is 50          |

**cURL Example**

```
curl -H "Content-Type: application/json" -H 'Accept: application/json'  -X GET  http://mapwarper.net/api/v1/stats?per_page=3&sort_key=user_id&sort_order=asc -b cookie
```

**Response**

```
{
	"data": [
		{
			"user_id": 2,
			"username": null,
			"total_count": 646,
			"gcp_count": 244,
			"map_count": 402,
			"gcp_update_count": 90,
			"gcp_create_count": 94,
			"gcp_destroy_count": 60,
			"id": null
		},
		{
			"user_id": 11,
			"username": null,
			"total_count": 3,
			"gcp_count": 0,
			"map_count": 3,
			"gcp_update_count": 0,
			"gcp_create_count": 0,
			"gcp_destroy_count": 0,
			"id": null
		}
	],
	"meta": {
		"total_entries": 5,
		"total_pages": 2
	}
}
```

**Response Elements**


***Data***

| Name              | Type    | Description                  | Notes |
|-------------------|---------|------------------------------|-------|
| total_count       | integer | total  number of changes     |       |
| map_count         | integer | number of map changes        |       |
| gcp_count         | integer | number of gcp changes        |       |
| gcp_update_count  | integer | number of gcp update changes |       |
| gcp_create_count  | integer | number of gcp creations      |       |
| gcp_destroy_count | integer | number of gcp deletions      |       |
| user_id           | integer | user id                      |       |

note: ```username``` and ```id``` are not used.

***Meta***

Useful in pagination. Will show the total number of results, for example if the request is limited to returning 25 maps:

```
"meta": {
  "total_entries": 50,
  "total_pages": 2
}
```
