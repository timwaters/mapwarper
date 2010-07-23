postgis_connection

ActiveRecord::Schema.define() do
  execute <<-SQL
    drop table if exists point_models;
    create table point_models
    (
    	id serial primary key,
    	extra varchar(255),
    	more_extra varchar(255)
    );
    select AddGeometryColumn('point_models', 'geom', 4326, 'POINT', 2);
    create index index_point_models_on_geom on point_models using gist (geom);
    create index index_point_models_on_extra on point_models (extra, more_extra);
    
    drop table if exists line_string_models;
    create table line_string_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('line_string_models', 'geom', 4326, 'LINESTRING', 2);

    drop table if exists polygon_models;
    create table polygon_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('polygon_models', 'geom', 4326, 'POLYGON', 2);

    drop table if exists multi_point_models;
    create table multi_point_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('multi_point_models', 'geom', 4326, 'MULTIPOINT', 2);

    drop table if exists multi_line_string_models;
    create table multi_line_string_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('multi_line_string_models', 'geom', 4326, 'MULTILINESTRING', 2);

    drop table if exists multi_polygon_models;
    create table multi_polygon_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('multi_polygon_models', 'geom', 4326, 'MULTIPOLYGON', 2);

    drop table if exists geometry_collection_models;
    create table geometry_collection_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('geometry_collection_models', 'geom', 4326, 'GEOMETRYCOLLECTION', 2);

    drop table if exists geometry_models;
    create table geometry_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('geometry_models', 'geom', 4326, 'GEOMETRY', 2);
    
    drop table if exists pointz_models;
    create table pointz_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('pointz_models', 'geom', 4326, 'POINT', 3);
    
    drop table if exists pointm_models;
    create table pointm_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('pointm_models', 'geom', 4326, 'POINTM', 3);

    drop table if exists point4_models;
    create table point4_models
    (
    	id serial primary key,
    	extra varchar(255)
    );
    select AddGeometryColumn('point4_models', 'geom', 4326, 'POINT', 4);
  SQL
  
  if ActiveRecord::Base.connection.supports_geographic?
    execute <<-SQL
      drop table if exists geography_point_models;
      create table geography_point_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(POINT)
      );
      create index index_geography_point_models_on_geom on geography_point_models using gist (geom);
      create index index_geography_point_models_on_extra on geography_point_models (extra);

      drop table if exists geography_line_string_models;
      create table geography_line_string_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(LINESTRING)
      );

      drop table if exists geography_polygon_models;
      create table geography_polygon_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(POLYGON)
      );

      drop table if exists geography_multi_point_models;
      create table geography_multi_point_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(MULTIPOINT)
      );

      drop table if exists geography_multi_line_string_models;
      create table geography_multi_line_string_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(MULTILINESTRING)
      );

      drop table if exists geography_multi_polygon_models;
      create table geography_multi_polygon_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(MULTIPOLYGON)
      );

      drop table if exists geography_geometry_collection_models;
      create table geography_geometry_collection_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(GEOMETRYCOLLECTION)
      );

      drop table if exists geography_models;
      create table geography_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography
      );

      drop table if exists geography_pointz_models;
      create table geography_pointz_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(POINTZ)
      );

      drop table if exists geography_pointm_models;
      create table geography_pointm_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(POINTM)
      );

      drop table if exists geography_point4_models;
      create table geography_point4_models
      (
      	id serial primary key,
      	extra varchar(255),
      	geom geography(POINTZM)
      );
    SQL
  end
end
