require 'fluent/output'
require_relative 'barito_timber'
require_relative 'barito_client_trail'
require_relative 'barito_transport'

module Fluent
  class BaritoBatchVMOutput < BufferedOutput

    PLUGIN_NAME = "barito_batch_vm"

    Fluent::Plugin.register_output(PLUGIN_NAME, self)

    config_param :application_secret, :string, :default => nil
    config_param :application_group_secret, :string, :default => nil
    config_param :application_name, :string, :default => nil
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
      data = {
        'items' => []
      }
      transport = Fluent::Plugin::BaritoTransport.new(@produce_url, log)
      chunk.msgpack_each do |tag, time, record|
        trail = Fluent::Plugin::ClientTrail.new(false)
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)

        data['items'] << timber
      end

      if @application_secret.nil? or @application_secret.empty?
          return if @application_group_secret.nil? or @application_name.nil?
          header = {
            content_type: :json,
            'X-App-Group-Secret' => @application_group_secret,
            'X-App-Name' => @application_name
          }
      else
        header = {content_type: :json, 'X-App-Secret' => @application_secret}
      end

      transport.send_compressed(data, header)
    end
  end
end