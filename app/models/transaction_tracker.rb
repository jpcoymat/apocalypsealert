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

  def remove_tracker(attribute_tracker)
    @attribute_trackers.delete(attribute_tracker.key)
  end
  
  def add_tracker(attribute_tracker)
    @attribute_trackers << attribute_tracker.key unless @attribute_trackers.include?(attribute_tracker.key)    
  end
  
  def reevaluate
    transaction = eval("#{@object_type_tracked}.find({@object_uid})")    
    attributes_to_check = eval("#{@object_type_tracked}.major_attributes")
    attributes_to_check.each do |attr_check|
      tracker_key = @attribute_trackers.bsearch {|at| at.include?(@object_type_tracked + ":" + attr_check.to_s)} 
      if tracker_key
        tracker_value = tracker_key[tracker_key.index("=")+1 .. tracker_key.length-1].to_i
        if tracker_value != transaction.try(attr_check)
          old_attr_tracker = AttributeTracker.new(@object_type_tracker, attr_check.to_s, tracker_value)
          old_attr_tracker.remove_transaction(@object_uid)
          remove_tracker(old_att_tracker)
          new_attr_tracker = AttributeTracker.new(@object_type_tracker, attr_check.to_s, transaction.try(attr_check).try(:to_s))
          new_attr_tracker.add_record(transaction)    
          add_tracker(new_att_tracker)
        end
      else
        new_attr_tracker = AttributeTracker.new(@object_type_tracker, attr_check.to_s, transaction.try(attr_check).try(:to_s))
        new_attr_tracker.add_record(transaction)
        add_tracker(new_att_tracker)
      end 
    end
    save
  end


end
