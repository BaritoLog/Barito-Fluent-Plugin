require 'socket'

class Fluent::Plugin::ClientTrail
  
  attr_accessor :is_k8s, :sent_at,  :hints

  def initialize(is_k8s)
    @is_k8s = is_k8s
    @sent_at = Time.now.utc.strftime('%FT%TZ')
    @hints = []
    @hostname = Socket.gethostname
  end

  def to_hash
    {
        'is_k8s' => @is_k8s,
        'sent_at' => @sent_at,
        'hints' => @hints,
        'hostname' => @hostname
    }
  end
  
end
