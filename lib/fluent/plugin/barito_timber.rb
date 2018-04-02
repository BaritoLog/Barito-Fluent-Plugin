class Fluent::Plugin::Timber
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
end
