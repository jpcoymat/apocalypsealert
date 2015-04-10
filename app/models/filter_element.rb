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
    @element_name.try(:titleize)
  end
  
  def options_for_collect
    options = ""
    @filter_options.each do |option|
      options += '<option value="' + option.try(:id) + '">' + option.try(:name) + '</option>'
    end
    return options
  end


end
   