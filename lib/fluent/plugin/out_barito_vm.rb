require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoOutput < BufferedOutput

    PLUGIN_NAME = "barito_vm"
    MESSAGE_KEY = "message"
    
    HINTS_NO_TIMESTAMP = "no timestamp".freeze
    HINTS_NO_MESSAGE = "no #{MESSAGE_KEY}".freeze

    Fluent::Plugin.register_output(PLUGIN_NAME, self)

    config_param :application_secret, :string, :default => nil
    config_param :produce_url, :string, :default => ''

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
      

        puts "----------------"
        
        timber = create_timber(tag, time, record)
        
        puts timber.to_json
  
        puts "----------------"
        
        # RestClient.post url, message, {content_type: :json, application_secret: @application_secret}
      end
    end
    
    def create_timber(tag, time, record)
      
      trail = Fluent::Plugin::ClientTrail.new
      trail.sent_at = Time.now.utc
      trail.is_k8s = false
      trail.hints = []
      
      timber = Fluent::Plugin::Timber.new
      timber.tag = tag
      timber.timestamp = time
      timber.message = record[MESSAGE_KEY] if record.is_a?(Hash) and record.has_key?(MESSAGE_KEY)
      timber.client_trail = trail
      
      if timber.timestamp.nil? 
        timber.timestamp = Time.now.utc
        trail.hints << HINTS_NO_TIMESTAMP
      end
      
      if timber.message.nil? or timber.message.empty? 
        timber.message = record.to_str
        trail.hints << HINTS_NO_MESSAGE
      end
      
      timber
      
    end
  end
  

end
