# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170401143358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type",   limit: 255
    t.integer  "user_id"
    t.string   "user_type",        limit: 255
    t.string   "username",         limit: 255
    t.string   "action",           limit: 255
    t.text     "audited_changes"
    t.integer  "version",                      default: 0
    t.datetime "created_at"
    t.string   "comment"
    t.string   "remote_address"
    t.integer  "association_id"
    t.string   "association_type"
  end

  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "client_applications", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "url",          limit: 255
    t.string   "support_url",  limit: 255
    t.string   "callback_url", limit: 255
    t.string   "key",          limit: 20
    t.string   "secret",       limit: 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], name: "index_client_applications_on_key", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "title",            limit: 50,  default: ""
    t.text     "comment",                      default: ""
    t.integer  "commentable_id"
    t.string   "commentable_type", limit: 255
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "gcps", force: :cascade do |t|
    t.integer  "map_id"
    t.float    "x"
    t.float    "y"
    t.decimal  "lat",                    precision: 15, scale: 10
    t.decimal  "lon",                    precision: 15, scale: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "soft",                                             default: false
    t.string   "name",       limit: 255
  end

  add_index "gcps", ["soft"], name: "index_gcps_on_soft", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description"
    t.integer  "creator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_maps", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups_maps", ["map_id", "group_id"], name: "index_groups_maps_on_map_id_and_group_id", unique: true, using: :btree
  add_index "groups_maps", ["map_id"], name: "index_groups_maps_on_map_id", using: :btree

  create_table "imports", force: :cascade do |t|
    t.string   "path",                  limit: 255
    t.string   "name",                  limit: 255
    t.string   "layer_title",           limit: 255
    t.string   "map_title_suffix",      limit: 255
    t.string   "map_description",       limit: 255
    t.string   "map_publisher",         limit: 255
    t.string   "map_author",            limit: 255
    t.string   "state",                 limit: 255
    t.integer  "layer_id"
    t.integer  "uploader_user_id"
    t.integer  "user_id"
    t.integer  "file_count"
    t.integer  "imported_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.boolean  "save_layer"
    t.string   "log_filename"
    t.string   "metadata_file_name"
    t.string   "metadata_content_type"
    t.integer  "metadata_file_size"
    t.datetime "metadata_updated_at"
  end

  create_table "imports_layers", force: :cascade do |t|
    t.integer "import_id"
    t.integer "layer_id"
  end

  add_index "imports_layers", ["import_id"], name: "index_imports_layers_on_import_id", using: :btree
  add_index "imports_layers", ["layer_id"], name: "index_imports_layers_on_layer_id", using: :btree

  create_table "layers", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.text     "description"
    t.string   "bbox",                 limit: 255
    t.integer  "owner"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "depicts_year",         limit: 4,                            default: ""
    t.integer  "maps_count",                                                default: 0
    t.integer  "rectified_maps_count",                                      default: 0
    t.boolean  "is_visible",                                                default: true
    t.string   "source_uri",           limit: 255
    t.geometry "bbox_geom",            limit: {:srid=>0, :type=>"polygon"}
  end

  add_index "layers", ["bbox_geom"], name: "index_layers_on_bbox_geom", using: :gist

  create_table "layers_maps", force: :cascade do |t|
    t.integer  "layer_id"
    t.integer  "map_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "layers_maps", ["layer_id"], name: "index_layers_maps_on_layer_id", using: :btree
  add_index "layers_maps", ["map_id"], name: "index_layers_maps_on_map_id", using: :btree

  create_table "maps", force: :cascade do |t|
    t.string   "title",                  limit: 255
    t.text     "description"
    t.string   "filename",               limit: 255
    t.integer  "width"
    t.integer  "height"
    t.integer  "status"
    t.integer  "mask_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "upload_file_name",       limit: 255
    t.string   "upload_content_type",    limit: 255
    t.integer  "upload_file_size"
    t.datetime "upload_file_updated_at"
    t.string   "bbox",                   limit: 255
    t.string   "publisher",              limit: 255
    t.string   "authors",                limit: 255
    t.string   "scale",                  limit: 255
    t.datetime "published_date"
    t.datetime "reprint_date"
    t.integer  "owner_id"
    t.boolean  "public",                                                                                default: true
    t.boolean  "downloadable",                                                                          default: true
    t.string   "cached_tag_list",        limit: 255
    t.integer  "map_type"
    t.string   "source_uri",             limit: 255
    t.geometry "bbox_geom",              limit: {:srid=>0, :type=>"polygon"}
    t.decimal  "rough_lat",                                                   precision: 15, scale: 10
    t.decimal  "rough_lon",                                                   precision: 15, scale: 10
    t.geometry "rough_centroid",         limit: {:srid=>0, :type=>"point"}
    t.integer  "rough_zoom"
    t.integer  "rough_state"
    t.integer  "import_id"
    t.string   "publication_place",      limit: 255
    t.string   "subject_area",           limit: 255
    t.string   "unique_id",              limit: 255
    t.string   "metadata_projection",    limit: 255
    t.decimal  "metadata_lat",                                                precision: 15, scale: 10
    t.decimal  "metadata_lon",                                                precision: 15, scale: 10
    t.string   "date_depicted",          limit: 4,                                                      default: ""
    t.string   "call_number",            limit: 255
    t.datetime "rectified_at"
    t.datetime "gcp_touched_at"
    t.integer  "issue_year"
  end

  add_index "maps", ["bbox_geom"], name: "index_maps_on_bbox_geom", using: :gist
  add_index "maps", ["rough_centroid"], name: "index_maps_on_rough_centroid", using: :gist

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memberships", ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true, using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "my_maps", force: :cascade do |t|
    t.integer  "map_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "my_maps", ["map_id", "user_id"], name: "index_my_maps_on_map_id_and_user_id", unique: true, using: :btree
  add_index "my_maps", ["map_id"], name: "index_my_maps_on_map_id", using: :btree

  create_table "oauth_nonces", force: :cascade do |t|
    t.string   "nonce",      limit: 255
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], name: "index_oauth_nonces_on_nonce_and_timestamp", unique: true, using: :btree

  create_table "oauth_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",                  limit: 20
    t.integer  "client_application_id"
    t.string   "token",                 limit: 20
    t.string   "secret",                limit: 40
    t.string   "callback_url",          limit: 255
    t.string   "verifier",              limit: 20
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], name: "index_oauth_tokens_on_token", unique: true, using: :btree

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "pg_search_documents", ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable_type_and_searchable_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "updated_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type", limit: 255
    t.datetime "created_at"
    t.string   "context",       limit: 128
    t.integer  "tagger_id"
    t.string   "tagger_type"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "index_taggings_on_taggable_id_and_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count",             default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "encrypted_password",        limit: 128, default: "",   null: false
    t.string   "password_salt",                         default: "",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.string   "reset_password_token"
    t.boolean  "enabled",                               default: true
    t.integer  "updated_by"
    t.text     "description",                           default: ""
    t.datetime "confirmation_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "reset_password_sent_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "authentication_token",      limit: 30
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree

end
