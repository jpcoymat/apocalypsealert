class Filter

  attr_accessor :filter_elements
  attr_accessor :filter_name
  
  def initialize(filter_name: nil, filter_elements: nil)
    local_variables.each do |k|
      v = eval(k.to_s)
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end
  

end