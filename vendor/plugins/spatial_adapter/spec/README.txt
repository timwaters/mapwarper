= Running Tests

You will need to set up empty databases for each adapter you want to test.

== PostgreSQL

Create an empty database "spatial_adapter" and ensure that the PostGIS extensions are loaded.  

run "rake spec:postgis" to run the specs

== MySQL

Create an empty database "spatial_adapter" - the spatial extensions are already available.

run "rake spec:mysql" to run the specs

