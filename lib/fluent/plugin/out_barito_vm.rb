require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoOutput < BufferedOutput

    PLUGIN_NAME = "barito_vm"
    TIMESTAMP_FIELD = "@timestamp"
    MESSAGE_FIELD = "@message"

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
      
      chunk.msgpack_each {|tag, time, record|
      

        puts "----------------"
        
        trail = Fluent::Plugin::ClientTrail.new
        trail.sent_at = Time.now.utc
        trail.is_k8s = false
        
        timber = Fluent::Plugin::Timber.new
        timber.tag = tag
        timber.timestamp = time
        timber.message = record["message"]
        timber.client_trail = trail
        
        puts timber.to_json
  
        puts "----------------"
        
        # RestClient.post url, message, {content_type: :json, application_secret: @application_secret}
      }
    end
    
  end
end
