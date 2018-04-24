class Fluent::Plugin::TimberFactory
  MESSAGE_KEY = "message"
  
  HINTS_NO_TIMESTAMP = "no timestamp".freeze
  HINTS_NO_MESSAGE = "no #{MESSAGE_KEY}".freeze
  
  def self.create_timber(tag, time, record, trail)
    
    timestamp = Time.at(time).utc.strftime('%FT%TZ') # TODO: get from record
    message = record[MESSAGE_KEY] if record.is_a?(Hash) and record.has_key?(MESSAGE_KEY)
    client_trail = trail
    
    if timestamp.nil? 
      timestamp = Time.now.utc.strftime('%FT%TZ')
      trail.hints << HINTS_NO_TIMESTAMP
    end
    
    if message.nil? or message.empty? 
      message = record.to_str
      trail.hints << HINTS_NO_MESSAGE
    end
    
    {
      'tag' => tag,
      '@message' => message, 
      '@timestamp' => timestamp,
      'client_trail' => client_trail.to_hash
    }
    
  end
end
