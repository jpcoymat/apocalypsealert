class TransactionTracker

  attr_accessor :key
  attr_accessor :attribute_trackers
  attr_accessor :object_type_tracked
  attr_accessor :object_uid
  
  def compose_key
    @key = @object_type_tracked + ":" + @object_uid
  end

  def redis_value
    value_as_string = $redis.get(@key)
    if value_as_string
      return JSON.load(value_as_string).sort!
    else
      return []  
    end
  end

  def save
    @attribute_trackers.sort!
    $redis.set(@key, @attribute_trackers)
  end

  def initialize(transaction)
    @object_uid = transaction.try(:id).to_s
    @object_type_tracked = transaction.class.to_s
    compose_key
    @attribute_trackers = redis_value
  end

  def remove_tracker(attribute_tracker)
    @attribute_trackers.delete(attribute_tracker.key)
  end
  
  def add_tracker(attribute_tracker)
    @attribute_trackers << attribute_tracker.key unless @attribute_trackers.include?(attribute_tracker.key)    
  end
  
  def reload
    @attribute_trackers = redis_value
  end


end
