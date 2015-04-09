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
      @value = JSON.parse(redis_value).sort
    else
      @value = []
    end
  end

  def save
    $redis.set(@key, @value)
  end   

  def add_transaction(transaction)
    unless transaction_exists?(transaction)
      array_index = index_to_insert(transaction)
      @value.insert(array_index, transaction.try(:id))
    end
  end

  def remove_transaction(transaction)
    @value.delete(transaction.try(:id))
  end
  
  def reload
    @value = redis_value
  end
  
  def transaction_exists?(transaction)
    transaction_id = @value.bsearch {|elem| elem == transaction.try(:id)}
    transaction_id.nil? ? tran_exists = false : tran_exists = true
    return tran_exists 
  end
  
  def index_to_insert(transaction)
    index_value = @value.index(@value.bsearch {|elem| transaction.try(:id) < elem})
    index_value.nil? ? index_value = @value.length : nil
    return index_value
  end
  

end
