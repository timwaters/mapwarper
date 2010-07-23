# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100722165440) do

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "gcps", :force => true do |t|
    t.integer  "map_id"
    t.float    "x"
    t.float    "y"
    t.decimal  "lat",        :precision => 15, :scale => 10
    t.decimal  "lon",        :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "indshp", :primary_key => "gid", :force => true do |t|
    t.float         "altitude"
    t.float         "borocode"
    t.string        "boroname",     :limit => 254
    t.float         "plate_num"
    t.float         "hist_year"
    t.string        "author",       :limit => 254
    t.float         "volume_num"
    t.float         "url"
    t.float         "x"
    t.float         "y"
    t.float         "objectid"
    t.float         "altitude__11"
    t.float         "nypl_digit"
    t.float         "date_"
    t.float         "shape_leng"
    t.float         "shape_area"
    t.float         "plate_numb"
    t.float         "altitude_"
    t.multi_polygon "the_geom",                    :srid => 9804
  end

  create_table "layers", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "bbox"
    t.integer  "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "depicts_year",         :limit => 4, :default => ""
    t.integer  "maps_count",                        :default => 0
    t.integer  "rectified_maps_count",              :default => 0
    t.boolean  "is_visible",                        :default => true
    t.string   "source_uri"
  end

  create_table "layers_maps", :force => true do |t|
    t.integer  "layer_id"
    t.integer  "map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "layers_maps", ["layer_id"], :name => "index_layers_maps_on_layer_id"
  add_index "layers_maps", ["map_id"], :name => "index_layers_maps_on_map_id"

  create_table "maps", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "filename"
    t.integer  "width"
    t.integer  "height"
    t.integer  "status"
    t.integer  "mask_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name"
    t.string   "upload_content_type"
    t.integer  "upload_file_size"
    t.datetime "upload_file_updated_at"
    t.string   "bbox"
    t.string   "publisher"
    t.string   "authors"
    t.string   "scale"
    t.datetime "published_date"
    t.datetime "reprint_date"
    t.integer  "owner_id"
    t.boolean  "public",                 :default => true
    t.boolean  "downloadable",           :default => true
    t.string   "cached_tag_list"
    t.integer  "map_type"
    t.string   "source_uri"
    t.polygon  "bbox_geom"
  end

  add_index "maps", ["bbox_geom"], :name => "index_maps_on_bbox_geom", :spatial => true

  create_table "my_maps", :force => true do |t|
    t.integer  "map_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "my_maps", ["map_id", "user_id"], :name => "index_my_maps_on_map_id_and_user_id", :unique => true
  add_index "my_maps", ["map_id"], :name => "index_my_maps_on_map_id"

  create_table "parks", :id => false, :force => true do |t|
    t.integer       "park_id",                  :null => false
    t.string        "park_name", :limit => nil
    t.string        "park_type", :limit => nil
    t.multi_polygon "park_geom"
    t.integer       "size"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "planet_osm_line", :id => false, :force => true do |t|
    t.integer     "osm_id"
    t.text        "access"
    t.text        "admin_level"
    t.text        "aerialway"
    t.text        "aeroway"
    t.text        "amenity"
    t.text        "area"
    t.text        "bicycle"
    t.text        "bridge"
    t.text        "boundary"
    t.text        "building"
    t.text        "cutting"
    t.text        "embankment"
    t.text        "foot"
    t.text        "highway"
    t.text        "horse"
    t.text        "junction"
    t.text        "landuse"
    t.text        "layer"
    t.text        "learning"
    t.text        "leisure"
    t.text        "man_made"
    t.text        "military"
    t.text        "motorcar"
    t.text        "name"
    t.text        "natural"
    t.text        "oneway"
    t.text        "power"
    t.text        "place"
    t.text        "railway"
    t.text        "ref"
    t.text        "religion"
    t.text        "residence"
    t.text        "route"
    t.text        "sport"
    t.text        "tourism"
    t.text        "tracktype"
    t.text        "tunnel"
    t.text        "waterway"
    t.text        "width"
    t.text        "wood"
    t.integer     "z_order"
    t.float       "way_area"
    t.line_string "way",         :srid => 900913
  end

  add_index "planet_osm_line", ["way"], :name => "planet_osm_line_index", :spatial => true

  create_table "planet_osm_point", :id => false, :force => true do |t|
    t.integer "osm_id"
    t.text    "access"
    t.text    "admin_level"
    t.text    "aeroway"
    t.text    "amenity"
    t.text    "area"
    t.text    "bicycle"
    t.text    "bridge"
    t.text    "boundary"
    t.text    "building"
    t.text    "cutting"
    t.text    "embankment"
    t.text    "foot"
    t.text    "highway"
    t.text    "horse"
    t.text    "junction"
    t.text    "landuse"
    t.text    "layer"
    t.text    "learning"
    t.text    "leisure"
    t.text    "man_made"
    t.text    "military"
    t.text    "motorcar"
    t.text    "name"
    t.text    "natural"
    t.text    "oneway"
    t.text    "poi"
    t.text    "power"
    t.text    "place"
    t.text    "railway"
    t.text    "ref"
    t.text    "religion"
    t.text    "residence"
    t.text    "route"
    t.text    "sport"
    t.text    "tourism"
    t.text    "tunnel"
    t.text    "waterway"
    t.text    "width"
    t.text    "wood"
    t.integer "z_order"
    t.point   "way",         :srid => 900913
  end

  add_index "planet_osm_point", ["way"], :name => "planet_osm_point_index", :spatial => true

  create_table "planet_osm_polygon", :id => false, :force => true do |t|
    t.integer "osm_id"
    t.text    "access"
    t.text    "admin_level"
    t.text    "aerialway"
    t.text    "aeroway"
    t.text    "amenity"
    t.text    "area"
    t.text    "bicycle"
    t.text    "bridge"
    t.text    "boundary"
    t.text    "building"
    t.text    "cutting"
    t.text    "embankment"
    t.text    "foot"
    t.text    "highway"
    t.text    "horse"
    t.text    "junction"
    t.text    "landuse"
    t.text    "layer"
    t.text    "learning"
    t.text    "leisure"
    t.text    "man_made"
    t.text    "military"
    t.text    "motorcar"
    t.text    "name"
    t.text    "natural"
    t.text    "oneway"
    t.text    "power"
    t.text    "place"
    t.text    "railway"
    t.text    "ref"
    t.text    "religion"
    t.text    "residence"
    t.text    "route"
    t.text    "sport"
    t.text    "tourism"
    t.text    "tracktype"
    t.text    "tunnel"
    t.text    "waterway"
    t.text    "width"
    t.text    "wood"
    t.integer "z_order"
    t.float   "way_area"
    t.polygon "way",         :srid => 900913
  end

  add_index "planet_osm_polygon", ["way"], :name => "planet_osm_polygon_index", :spatial => true

  create_table "planet_osm_roads", :id => false, :force => true do |t|
    t.integer     "osm_id"
    t.text        "access"
    t.text        "admin_level"
    t.text        "aerialway"
    t.text        "aeroway"
    t.text        "amenity"
    t.text        "area"
    t.text        "bicycle"
    t.text        "bridge"
    t.text        "boundary"
    t.text        "building"
    t.text        "cutting"
    t.text        "embankment"
    t.text        "foot"
    t.text        "highway"
    t.text        "horse"
    t.text        "junction"
    t.text        "landuse"
    t.text        "layer"
    t.text        "learning"
    t.text        "leisure"
    t.text        "man_made"
    t.text        "military"
    t.text        "motorcar"
    t.text        "name"
    t.text        "natural"
    t.text        "oneway"
    t.text        "power"
    t.text        "place"
    t.text        "railway"
    t.text        "ref"
    t.text        "religion"
    t.text        "residence"
    t.text        "route"
    t.text        "sport"
    t.text        "tourism"
    t.text        "tracktype"
    t.text        "tunnel"
    t.text        "waterway"
    t.text        "width"
    t.text        "wood"
    t.integer     "z_order"
    t.float       "way_area"
    t.line_string "way",         :srid => 900913
  end

  add_index "planet_osm_roads", ["way"], :name => "planet_osm_roads_index", :spatial => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "password_reset_code",       :limit => 40
    t.boolean  "enabled",                                 :default => true
    t.integer  "updated_by"
  end

end
