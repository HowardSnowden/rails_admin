module RailsAdmin
  module Config
    module Actions
      class Edit < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :http_methods do
          [:get, :put]
        end

        register_instance_option :controller do
          proc do
            if request.get? # EDIT

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.put? # UPDATE
              sanitize_params_for!(request.xhr? ? :modal : :update)

              attributes = params[@abstract_model.param_key]
              @object.set_attributes(attributes)
              @authorization_adapter && @authorization_adapter.attributes_for(:update, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end
              changes = @object.changes
              if @object.save
                @auditing_adapter && @auditing_adapter.update_object(@object, @abstract_model, _current_user, changes)
                respond_to do |format|
                  format.html { redirect_to_on_success }
                  format.js do
                    if params[:inline].to_b
                      field_name, field_value = attributes.to_h.first
                      field = @model_config.list.with(controller: self, object: @object).visible_fields.find{ |f| f.name == field_name.to_sym }
                      render json: {title: field.pretty_value, value: field_value}
                    else
                      render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label}
                    end
                  end
                end
              else
                handle_save_error :edit
              end

            end
          end
        end

        register_instance_option :link_icon do
          'icon-pencil'
        end
      end
    end
  end
end
