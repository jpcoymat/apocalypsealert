# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( chosen-jquery.js )
Rails.application.config.assets.precompile += %w( sigma.js )
Rails.application.config.assets.precompile += %w( sigma-json.js)
Rails.application.config.assets.precompile += %w( chosen-bootstrap.css)
Rails.application.config.assets.precompile += %w( chosen-sprite.png)
Rails.application.config.assets.precompile += %w(chosen-sprite@2x.png)

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
