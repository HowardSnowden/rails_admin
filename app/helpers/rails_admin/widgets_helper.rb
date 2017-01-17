module RailsAdmin
  module WidgetsHelper
    def edit_inline_widget(object, property)
      model, id, name = object.class.to_admin_param, object.id, property.name
      model_name = model.tr('~', '_')

      class_attr = [property.css_class, property.type_css_class, 'js_edit_inline_input']
      data_attr = {model: model, id: id, name: name}

      content_tag :td, class: class_attr, data: data_attr do

        name_attr = "#{model_name}[#{id}][#{name}]"
        id_attr = "#{model_name}_#{id}_#{name}"
        value_attr = object.send(name)

        case property.type
        when :boolean
          send "#{property.view_helper}_tag", name_attr, value_attr, value_attr, id: id_attr
        else
          send "#{property.view_helper}_tag", name_attr, value_attr, id: id_attr
        end
      end
    end

    def infinite_scroll_widget
      content_tag :li, class: ['next', 'js_infinite_scroll'] do
        link_to t('admin.widgets.infinite_scroll.more'), '#', class: 'btn btn-default'
      end
    end
  end
end
