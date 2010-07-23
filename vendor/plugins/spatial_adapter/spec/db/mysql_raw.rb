mysql_connection

ActiveRecord::Schema.define() do
  execute "drop table if exists point_models"
  execute "create table point_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	more_extra varchar(255),
    	geom  point not null
    ) ENGINE=MyISAM"
  execute "create spatial index index_point_models_on_geom on point_models (geom)"
  execute "create index index_point_models_on_extra on point_models (extra, more_extra)"
    
  execute "drop table if exists line_string_models"
  execute "create table line_string_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom linestring
    ) ENGINE=MyISAM"
    
  execute "drop table if exists polygon_models"
  execute "create table polygon_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom polygon
    ) ENGINE=MyISAM"
    
  execute "drop table if exists multi_point_models"
  execute "create table multi_point_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom multipoint
    ) ENGINE=MyISAM"
    
  execute "drop table if exists multi_line_string_models"
  execute "create table multi_line_string_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom multilinestring
    ) ENGINE=MyISAM"
    
  execute "drop table if exists multi_polygon_models"
  execute "create table multi_polygon_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom multipolygon
    ) ENGINE=MyISAM"
    
  execute "drop table if exists geometry_collection_models"
  execute "create table geometry_collection_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom geometrycollection
    ) ENGINE=MyISAM"
    
  execute "drop table if exists geometry_models"
  execute "create table geometry_models
    (
    	id int(11) DEFAULT NULL auto_increment PRIMARY KEY,
    	extra varchar(255),
    	geom geometry
    ) ENGINE=MyISAM"
end
