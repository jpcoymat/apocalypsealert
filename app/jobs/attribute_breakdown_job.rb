class AttributeBreakdownJob

  @queue = :attribute_breakdown
  
  def self.perform(json_string)
    object_hash = JSON.load(json_string)
    attributes = eval("#{object_hash["object_class"]}.major_attributes")
    transaction = eval("#{object_hash["object_class"]}.find(#{object_hash["object_id"]})")
    transaction_tracker = TransactionTracker.new(transaction)
    attributes.each do |mjr_attr| 
      transaction_tracker.reload 
      transaction_value = transaction.try(mjr_attr)
      current_attribute_tracker_key = get_tracker_key_from_attribute_name(transaction_tracker.attribute_trackers, mjr_attr)
      if current_attribute_tracker_key.nil?
        at = AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, transaction_value.to_s)
        at.add_transaction(transaction)
        at.save 
        transaction_tracker.add_tracker(at)
        transaction_tracker.save   
      elsif value_from_key(current_attribute_tracker_key) != transaction_value
        old_tracker = AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, value_from_key(current_attribute_tracker_key))
        old_tracker.remove_transaction(transaction)
        old_tracker.save
        transaction_tracker.remove_tracker(old_tracker) 
        new_tracker =  AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, transaction_value)
        new_tracker.add_transaction(transaction)
        new_tracker.save
        transaction_tracker.add_tracker(new_tracker)
        transaction_tracker.save
      end
      
    end    
  end

  def self.value_from_key(key)
    value_in_key = key[key.index("=")+1 .. key.length-1]
    value_in_key =~ /\A\d+\z/ ? value_in_key = value_in_key.to_i : nil
    return value_in_key
  end

  def self.attribute_from_key(object_class, key)
    return key[object_class.length+1 .. key.index("=")-1]
  end

  def self.get_tracker_key_from_attribute_name(attribute_tracker_list, attribute_name)
    key_index =  attribute_tracker_list.index {|attr_trkr| attr_trkr.to_s.include?(attribute_name.to_s)} 
    key_index.nil? ? key_string = nil : key_string = attribute_tracker_list[key_index]
    return key_string
  end


end
