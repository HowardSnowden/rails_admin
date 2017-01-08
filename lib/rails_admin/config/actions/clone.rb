module RailsAdmin
  module Config
    module Actions
      class Clone < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :http_methods do
          [:get]
        end

        register_instance_option :controller do
          proc do
            respond_to do |format|
              format.html { render @action.template_name }
              format.js   { render @action.template_name, layout: false }
            end
          end
        end

        register_instance_option :link_icon do
          'fa fa-clone'
        end
      end
    end
  end
end
