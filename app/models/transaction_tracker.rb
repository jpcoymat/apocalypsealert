class TransactionTracker

  attr_accessor :key
  attr_accessor :attribute_trackers
  attr_accessor :object_type_tracked
  attr_accessor :object_uid
  
  def compose_key
    @key = @object_type_tracked + ":" + @object_uid
  end

  def redis_value
    return $redis.get(@key)   
  end

  def save
    $redis.set(@key, @attribute_trackers)
  end

  def initialize(transaction)
    @object_uid = transaction.try(:id).to_s
    @object_type_tracked = transaction.class.to_s
    compose_key
    @attribute_trackers = redis_value
  end

  def reevaluate
    transaction = eval("#{@object_type_tracked}.find({@object_uid})")
    attribute_trackers.each do |at_element|
      start_position = at.index(@object_type_tracked + 1)
      end_position = at.index("=")
      attribute_name = at[start_position .. end_position-1]
      tracker_value = at[end_position+1 .. at.length-1].to_i
      unless transaction.try(attribute_name.to_sym) == tracker_value
        old_att_tracker = AttributeTracker.new(object_type_tracked, attribute_name, tracker_value)
        old_att_tracker.remove_transaction(@object_uid)
        new_att_tracker = AttributeTracker.new(object_type_tracked, attribute_name, transaction.try(attribute_name.to_sym))
        new_att_tracker.add_record(transaction)
      end
    end
  end

end