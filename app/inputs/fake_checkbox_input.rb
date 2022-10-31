class FakeCheckboxInput < SimpleForm::Inputs::StringInput
    # This method only create a basic input without reading any value from object
    def input(wrapper_options = nil)
      merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
      tag_name = "#{@builder.object_name}[#{attribute_name}]"
      template.check_box_tag(tag_name, options['value'] || 1, options['checked'], merged_input_options)
    end
  end