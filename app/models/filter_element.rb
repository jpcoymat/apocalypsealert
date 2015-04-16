class FilterElement

  attr_accessor :element_name
  attr_accessor :element_value
  attr_accessor :enabled_for_quick_filter
  attr_accessor :multiselectable
  attr_accessor :typeahead_enabled
  attr_accessor :filter_options
  
  def initialize(element_name: nil, element_value: nil, multiselectable: nil, enabled_for_quick_filter: nil, typeahead_enabled: nil, filter_options: nil)
    local_variables.each do |k|
      v = eval(k.to_s)
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
 
  def display_name
    @element_name.gsub("_id","").try(:titleize)
  end
  
  def filter_select_options
    options_string = ""
    @filter_options.each do |filter_option|
      if filter_option.class.to_s == "String"
        options_string += '<option value="' + filter_option + '">' + filter_option + '</option>'
      else
        options_string += '<option value="' + filter_option.try(:id).try(:to_s) + '">' + filter_option.try(:name).try(:to_s) + '</option>'
      end      
    end
    return options_string
  end
  

end
   