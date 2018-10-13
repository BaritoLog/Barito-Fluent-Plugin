require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoVMOutput < BufferedOutput

    PLUGIN_NAME = "barito_vm"

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
      chunk.msgpack_each do |tag, time, record|
        trail = Fluent::Plugin::ClientTrail.new(false)
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)

        if @application_secret.nil? or @application_secret.blank?
          next if @application_group_secret.nil? or @application_name.nil?
          header = {
            content_type: :json,
            'X-App-Group-Secret' => @application_group_secret,
            'X-App-Name' => @application_name
          }
        else
          header = {content_type: :json, 'X-App-Secret' => @application_secret}
        end

        RestClient.post @produce_url, timber.to_json, header
      end
    end
  end
end
