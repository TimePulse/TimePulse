module JsTemplateHelper
  Open = "::A::"
  Close = "::Z::"

  module TemplateModel
    def pretend_columns
      @pretend_columns ||= Hash.new do |h,k|
        h[k]= ActiveRecord::ConnectionAdapters::Column.new(k, nil, "text")
      end
    end

    def column_for_attribute(attr_name)
      pretend_columns[attr_name]
    end

    def to_param
      return @attributes["id"]
    end
  end

  def js_template_model(klass)
    model = klass.new do |mod|
      js_template_model_setup(mod)
    end
  end

  class TemplateValue < String
    def to_s(*args)
      return self
    end

    undef upcase
    undef truncate

    def method_missing(*args)
      return self
    end
  end

  def unescape_template_delims(text)
    text.gsub(%r[#{Open}((?:.(?!#{Close}))*.)#{Close}], '{{\1}}')
  end

  def js_template_render(*args, &block)
    unescape_template_delims(render(*args, &block))
  end

  def js_template_model_setup(model, prefix=[])
    return if prefix.length > 3 #Why do you need access this deep?
    model.extend(TemplateModel)
    [*model.attribute_names, "id"].each do |name|
      path = [*prefix, name]
      Rails.logger.debug{{ name => path }}
      model[name] = TemplateValue.new("#{Open}#{path.join(".")}#{Close}")
    end
    Rails.logger.debug{ model.inspect }
    model.class.reflections.each_pair do |name, reflection|
      assoc = reflection.build_association
      js_template_model_setup(assoc, [*prefix, name])
      Rails.logger.debug{ { name => assoc.inspect }}
      if reflection.collection?
        model.send("#{name}=", [assoc])
      else
        model.send("#{name}=", assoc)
      end
    end
  end

  module Formbuilder
    include JsTemplateHelper
    def js_template_fields_for(assoc_name, field_options = {}, &block)
      builder = self.class.new(@object_name, js_template_model(@object.class), @template, @options, @proc)
      builder.fields_for(assoc_name, field_options.merge(:child_index => "#{Open}index#{Close}"), &block)
    end
  end
end

class ActionView::Helpers::FormBuilder
  include JsTemplateHelper::Formbuilder
end
