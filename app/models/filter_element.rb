class FilterElement

  attr_accessor :element_name
  attr_accessor :element_value
  attr_accessor :enabled_for_quick_filter
  attr_accessor :multiselectable
  attr_accessor :typeahead_enabled
  attr_accessor :filter_options
  
  def initialize(name)
    @element_name = name
  end

  


end
   