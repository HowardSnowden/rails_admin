require 'font-awesome-sass'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'nested_form'
require 'rack-pjax'
require 'rails'
require 'rails_admin'
require 'remotipart'
require 'hamlit-rails'
require 'bootstrap-sass'
require 'bootswatch-rails'
require 'twitter-typeahead-rails'
require 'bootstrap_datetimepicker_sass'
require 'nprogress-rails'
require 'roboto_fontface_rails'
require 'pjax_rails'
require 'amoeba'
require 'ext_ruby'

if Rails.env.development?
  require 'query_diet'
end

module RailsAdmin
  class Engine < Rails::Engine
    isolate_namespace RailsAdmin

    config.action_dispatch.rescue_responses['RailsAdmin::ActionNotAllowed'] = :forbidden

    initializer 'RailsAdmin precompile hook', group: :all do |app|
      app.config.assets.precompile += %w(
        rails_admin/rails_admin.js
        rails_admin/rails_admin.css
        rails_admin/jquery.colorpicker.js
        rails_admin/jquery.colorpicker.css
      )
    end

    initializer 'RailsAdmin setup middlewares' do |app|
      app.config.middleware.use ActionDispatch::Flash
      app.config.middleware.use Rack::Pjax
    end

    config.to_prepare do
      if Rails.env.development?
        RailsAdmin::Config.reset
        load "#{Rails.root}/config/initializers/rails_admin.rb"
      end

      # skip pjax_rails added callbacks
      ActionController::Base.send :define_method, :pjax_request? do
        false
      end

      if RailsAdmin.config.with_admin_concerns
        (Rails::Engine.subclasses.map(&:root) << Rails.root).each do |root|
          files = Dir[root.join('app', 'models', 'admin', '**', '*.rb')]
          if RailsAdmin.config.with_admin_concerns.to_s == 'reverse'
            files = files.reverse
          end
          files.each do |name|
            model = name.match(/app\/models\/admin\/(.+)\.rb/)[1].camelize.constantize
            model.include Admin
            model.include "Admin::#{model.name}".constantize
          end
        end
      end
    end

    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../tasks/*.rake')].each { |f| load f }
    end
  end
end
