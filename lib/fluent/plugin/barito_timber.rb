class Fluent::Plugin::Timber
  MESSAGE_KEY = "message"
  
  HINTS_NO_TIMESTAMP = "no timestamp".freeze
  HINTS_NO_MESSAGE = "no #{MESSAGE_KEY}".freeze
  
  attr_accessor :location, :tag, :message, :timestamp, :client_trail
  
  def to_hash 
    {
      'location' => @location, 
      'tag' => @tag,
      '@message' => @message, 
      '@timestamp' => @timestamp,
      'client_trail' => @client_trail.to_hash
    }
  end
  
  def to_json
    to_hash.to_json
  end
  
  def self.create_timber(tag, time, record, trail)
    
    timber = Fluent::Plugin::Timber.new
    timber.tag = tag
    timber.timestamp = Time.at(time).utc.strftime('%FT%TZ')
    timber.message = record[MESSAGE_KEY] if record.is_a?(Hash) and record.has_key?(MESSAGE_KEY)
    timber.client_trail = trail
    
    if timber.timestamp.nil? 
      timber.timestamp = Time.now.utc.strftime('%FT%TZ')
      trail.hints << HINTS_NO_TIMESTAMP
    end
    
    if timber.message.nil? or timber.message.empty? 
      timber.message = record.to_str
      trail.hints << HINTS_NO_MESSAGE
    end
    
    timber
    
  end
end
