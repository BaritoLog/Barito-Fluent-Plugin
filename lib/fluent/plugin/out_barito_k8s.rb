require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_k8s'
    LABEL_APP_SECRET = 'barito.applicationSecret'
    LABEL_PRODUCE_URL = 'barito.produceUrl'

    Fluent::Plugin.register_output(PLUGIN_NAME, self)

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
        params = record['kubernetes']['annotations']

        next if params.nil?
        url = produce_url(params)
        secret = application_secret(params)

        next if url.nil? or secret.nil?
        trail = Fluent::Plugin::ClientTrail.new(false)
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)
        header = {content_type: :json, 'X-App-Secret' => secret}

        RestClient.post url, timber.to_json, header
      end
    end

    def produce_url(params)
      params[LABEL_PRODUCE_URL]
    end

    def application_secret(params)
      params[LABEL_APP_SECRET]
    end
  end
end
