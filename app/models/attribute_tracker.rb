class AttributeTracker

  attr_accessor :key
  attr_accessor :value
  attr_accessor :object_type_tracked
  attr_accessor :attribute_name
  attr_accessor :attribute_value

  def compose_key
    @key = @object_type_tracked + ":" + @attribute_name + "=" + @attribute_value.to_s
  end

  def redis_value
    return $redis.get(@key)    
  end

  def initialize(object_type_tracked, attribute_name, attribute_value)
    @object_type_tracked = object_type_tracked
    @attribute_name = attribute_name
    @attribute_value = attribute_value
    compose_key
    if redis_value
      @value = JSON.parse(redis_value)
    else
      @value = []
    end
  end

  def save
    $redis.set(@key, @value)
  end   

  def add_record(record)
    if record.try(@attribute_name.to_sym) == @attribute_value and !(@value.include?(record.try(:id)))
      @value << record.try(:id)
      save
    end
  end

  def remove_transaction(transaction_id)
    if @value.include?(transaction_id)
      @value.delete(transaction_id)
      save
    end    
  end
  

end
