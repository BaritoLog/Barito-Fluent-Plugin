class Fluent::Plugin::TimberFactory
  MESSAGE_KEY = "message"
  
  HINTS_NO_TIMESTAMP = "no timestamp".freeze
  HINTS_NO_MESSAGE = "no #{MESSAGE_KEY}".freeze
  
  def self.create_timber(tag, time, record, trail)
    begin
      timber = JSON.parse(record[MESSAGE_KEY])
    rescue 
    end
    
    unless timber.is_a?(Hash) then
      timber = Hash.new
    end

    # Capture default information
    message = record[MESSAGE_KEY] if record.is_a?(Hash) and record.has_key?(MESSAGE_KEY)
    client_trail = trail
    timestamp = Time.now.utc.strftime('%FT%TZ')

    if message.nil? or message.empty? 
      message = record.to_s
      trail.hints << HINTS_NO_MESSAGE
    end

    timber['tag'] =  tag
    timber['@message'] = message
    timber['@timestamp'] = timestamp
    timber['client_trail'] = client_trail.to_hash

    timber    
  end
end
