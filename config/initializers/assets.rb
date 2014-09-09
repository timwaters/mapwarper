# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
 Rails.application.config.assets.precompile += %w(layer-maps.js geosearch.js geosearch-map.js geosearch-layer.js warped.js align.js clip.js warp.js openlayers/2.8/OpenLayers-2.8/OpenLayers.js )

Rails.application.config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif)

Rails.application.config.assets.precompile += %w( iD.js iD.css )
Rails.application.config.assets.precompile += %w( iD/img/*.svg iD/img/*.png iD/img/*.gif )
Rails.application.config.assets.precompile += %w( iD/img/pattern/*.png )
Rails.application.config.assets.precompile += %w( iD/locales/*.json )