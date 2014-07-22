CONFIG_PATH="#{Rails.root}/config/application.yml"

APP_CONFIG = YAML.load_file(CONFIG_PATH)[Rails.env]

ADDTHIS_TWITTER_USER = APP_CONFIG['addthis_twitter_user']
ADDTHIS_USER = APP_CONFIG['addthis_user']
GOOGLE_ANALYTICS_CODE  = APP_CONFIG['google_analytics_code']
GOOGLE_ANALYTICS_COOKIE_PATH = APP_CONFIG['google_analytics_cookie_path']
DST_MAPS_DIR = File.join(Rails.root, APP_CONFIG['dst_maps_dir'])
SRC_MAPS_DIR =  File.join(Rails.root, APP_CONFIG['src_maps_dir'])