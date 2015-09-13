module UeditorRails
  module Helpers
    module FormHelper
      extend ActiveSupport::Concern

      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::JavaScriptHelper

      def ueditor_text(object_name, method = nil, options = {})
        instance_tag = ActionView::Base::InstanceTag.new
        def instance_tag.add_default_name_and_id(options)
          if options.has_key?("index")
            options["name"] ||= tag_name_with_index(options["index"])
            options["id"] = options.fetch("id"){ tag_id_with_index(options["index"]) }
            options.delete("index")
          elsif defined?(@auto_index)
            options["name"] ||= tag_name_with_index(@auto_index)
            options["id"] = options.fetch("id"){ tag_id_with_index(@auto_index) }
          else
            options["name"] ||= tag_name
            options["id"] = options.fetch("id"){ tag_id }
          end

          options["name"] += "[]" if options["multiple"] && !options["name"].ends_with?("[]")
          options["id"] = [options.delete('namespace'), options["id"]].compact.join("_").presence
        end
        instance_tag.send(:add_default_name_and_id, options) if options[:id].blank?

        element_id = options.delete('id')
        ue_tag_attributes = {:type => 'text/plain', :id => element_id, :name => options.delete('name')}
        options[:initialFrameWidth] = options.delete(:width) unless options[:width].blank?
        options[:initialFrameHeight] = options.delete(:height) unless options[:height].blank?

        output_buffer = ActiveSupport::SafeBuffer.new
        #output_buffer << instance_tag.to_content_tag(:script, ue_tag_attributes)
        output_buffer << instance_tag.to_text_area_tag(ue_tag_attributes)
        output_buffer << javascript_tag {Util.js_replace(element_id, options.stringify_keys)}
        output_buffer
      end

    end
  end
end
