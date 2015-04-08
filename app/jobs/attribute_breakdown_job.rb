class AttributeBreakdownJob

  @queue = :attribute_breakdown
  
  def self.perform(json_string)
    object_hash = JSON.load(json_string)
    Resque.logger.info("Processing " + object_hash["object_class"] + " " + object_hash["object_id"].to_s)
    attributes = eval("#{object_hash["object_class"]}.major_attributes")
    transaction = eval("#{object_hash["object_class"]}.find(#{object_hash["object_id"]})")
    transaciton_tracker = TransactionTracker.new(transaction)
    attributes.each do |mjr_attr| 
      Resque.logger.info("checking attribute " + mjr_attr.to_s)
      transaction_value = transaction.try(mjr_attr)
      current_attribute_tracker_key = get_tracker_key_from_attribute_name(transaciton_tracker.attribute_trackers, mjr_attr)
      if current_attribute_tracker_key.nil?
        Resque.logger.info("No key found")
        at = AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, transaction_value.to_s)
        at.add_transaction(transaction)
        at.save 
        transaciton_tracker.add_tracker(at)
        transaciton_tracker.save   
      elsif value_from_key(current_attribute_tracker_key) != transaction_value
        Resque.logger.info("Transaction Value: " + transaction_value.to_s + " / Tracker Value: " + value_from_key(current_attribute_tracker_key).to_s)
        old_tracker = AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, value_from_key(current_attribute_tracker_key))
        old_tracker.remove_transaction(transaction)
        old_tracker.save
        transaciton_tracker.remove_tracker(old_tracker) 
        new_tracker =  AttributeTracker.new(object_hash["object_class"], mjr_attr.to_s, transaction_value)
        new_tracker.add_transaction(transaction)
        new_tracker.save
        transaciton_tracker.add_tracker(new_tracker)
        transaciton_tracker.save
      end
      transaction_tracker.reload 
    end    
  end

  def self.value_from_key(key)
    return key[key.index("=")+1 .. key.length-1].try(:to_i)
  end

  def self.attribute_from_key(object_class, key)
    return key[object_class.length+1 .. key.index("=")-1]
  end

  def self.get_tracker_key_from_attribute_name(attribute_tracker_list, attribute_name)
    return attribute_tracker_list.bsearch {|attr_trkr| attr_trkr.to_s.include?(attribute_name.to_s)} 
  end


end
