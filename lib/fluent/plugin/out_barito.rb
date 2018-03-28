require 'fluent/output'
require 'rest-client'

module Fluent
  class BaritoOutput < BufferedOutput

    TIMESTAMP_FIELD = "@timestamp"
    MESSAGE_FIELD = "@message"

    Fluent::Plugin.register_output("barito", self)

    config_param :use_https, :bool, :default => false
    config_param :use_kubernetes, :bool, :default => false

    config_param :application_secret, :string, :default => nil
    config_param :stream_id, :string, :default => ''
    config_param :store_id, :string, :default => ''
    config_param :client_id, :string, :default => ''
    config_param :forwarder_id, :string, :default => ''
    config_param :produce_host, :string, :default => ''
    config_param :produce_port, :string, :default => ''
    config_param :produce_topic, :string, :default => ''

    config_param :barito_market_url, :string, :default => nil
    config_param :produce_url, :string, :default => ''

    def start
      super
      @protocol = 'http'
      # get_config
    end

    # def get_config
    #   @barito_market_url ||= ENV['BARITO_MARKET_URL']
    #   @application_secret ||= ENV['BARITO_MARKET_APPLICATION_SECRET']
    #   response = RestClient.get @barito_market_url, {content_type: :json, application_secret: @application_secret}
    #   body = response.body
    #   unless body.nil?
    #     client = JSON.parse(body)
    #     @produce_url = client["client"]["produce_url"]
    #     if @produce_url.nil?
    #       log.error("Produce URL from BaritoMarket is nil")
    #     else
    #       log.info("Start with Produce URL : #{@produce_url}")
    #     end
    #   end
    # end

    def send_message(url, message)
      RestClient.post url, message, {content_type: :json, application_secret: @application_secret}
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def generate_produce_url
      unless @produce_url.nil? || @produce_url == ''
        return @produce_url
      end

      if @use_https
        @protocol = 'https'
      end

      return "#{@protocol}://#{@produce_host}:#{@produce_port}/str/#{@stream_id}/st/#{@store_id}/fw/#{@forwarder_id}/cl/#{@client_id}/produce/#{@produce_topic}"
    end

    def configure_params_k8(params)
      @application_secret = params['baritoApplicationSecret']
      @stream_id = params['baritoStreamId']
      @produce_host = params['baritoProduceHost']
      @produce_port = params['baritoProducePort']
      @produce_topic = params['baritoProduceTopic']
      @store_id = params['baritoStoreId']
      @forwarder_id = params['baritoForwarderId']
      @client_id = params['baritoClientId']
    end

    def write(chunk)
      chunk.msgpack_each {|(tag, time, record)|
        next unless record.is_a? Hash

        if @use_kubernetes
          next unless not record['kubernetes']['labels'].nil?
          params = record['kubernetes']['labels']
          configure_params_k8(params)

          next unless not @stream_id.nil? and @stream_id != ''
        end

        unless record.has_key?(TIMESTAMP_FIELD)
          t = Time.now.utc
          unless time.nil?
            if time.is_a?(Integer)
              t = Time.at(time)
            end
          end
          record[TIMESTAMP_FIELD] = t.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
        end
        
        record[MESSAGE_FIELD] = record.delete "message"

        message = record.to_json
        url = generate_produce_url

        send_message(url, message)
      }
    end
  end
end
