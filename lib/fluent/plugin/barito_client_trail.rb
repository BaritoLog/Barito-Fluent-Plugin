class Fluent::Plugin::ClientTrail
  
  attr_accessor :is_k8s, :sent_at, :hints
  
  def to_hash
    {
      'is_k8s' => @is_k8s,
      'sent_at' => @sent_at,
      'hints' => @hints
    }
  end
  
end
