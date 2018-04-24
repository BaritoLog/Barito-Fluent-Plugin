require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_k8s'
    
    LABEL_APP_SECRET = 'baritoApplicationSecret'
    LABEL_PRODUCE_HOST = 'baritoProduceHost'
    LABEL_PRODUCE_PORT = 'baritoProducePort'
    LABEL_PRODUCE_TOPIC = 'baritoProduceTopic'
    

    Fluent::Plugin.register_output(PLUGIN_NAME, self)
    
    config_param :use_https, :bool, :default => false
    

    # Overide from BufferedOutput
    def start
      super
    end

    # Overide from BufferedOutput
    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    # Overide from BufferedOutput
    def write(chunk)
      
      chunk.msgpack_each do |tag, time, record|
        labels = record['kubernetes']['labels']
        url = produce_url(labels)
        secret = application_secret(labels)
        
        trail = Fluent::Plugin::ClientTrail.new(true)
        
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)
        header = {content_type: :json, application_secret: secret}
        
        RestClient.post url, timber.to_json, header
      end
    end
    
    def produce_url(labels)
      produce_host = labels[LABEL_PRODUCE_HOST]
      produce_port = labels[LABEL_PRODUCE_PORT]
      produce_topic = labels[LABEL_PRODUCE_TOPIC]
      
      protocol = @use_https? 'https' : 'http'
      
      produce_url = "#{protocol}://#{produce_host}:#{produce_port}/produce/#{produce_topic}"
      produce_url
    end
    
    def application_secret(labels)
      labels[LABEL_APP_SECRET]
    end
    
    
  end
  

end
