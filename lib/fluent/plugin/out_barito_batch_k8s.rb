require 'fluent/output'
require_relative 'barito_timber'
require_relative 'barito_client_trail'
require_relative 'barito_transport'

module Fluent
  class BaritoBatchK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_batch_k8s'

    Fluent::Plugin.register_output(PLUGIN_NAME, self)

    config_param :application_secret, :string, :default => nil
    config_param :application_group_secret, :string, :default => nil
    config_param :application_name, :string, :default => nil
    config_param :produce_url, :string, :default => ''
    config_param :cluster_name, :string, :default => ''

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

        # Kubernetes annotations
        k8s_metadata = record['kubernetes']

        record = clean_attribute(record)
        trail = Fluent::Plugin::ClientTrail.new(true)
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)
        new_timber = merge_log_attribute(timber)

        # Add kubernetes information
        new_timber['k8s_metadata'] = {
          'pod_name' => k8s_metadata['pod_name'],
          'namespace_name' => k8s_metadata['namespace_name'],
          'container_name' => k8s_metadata['container_name'],
          'host' => k8s_metadata['host'],
          'cluster_name' => @cluster_name
        }

        data['items'] << new_timber
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

      transport.send(data, header)
    end

    def clean_attribute(record)
      # Delete kubernetes & docker field
      record.delete('kubernetes')
      record.delete('docker')
      record
    end

    def merge_log_attribute(record)
      message_log = nil
      begin
        message_log = JSON.parse(record['log'])
      rescue
      end

      if !message_log.nil?
        return record.merge(message_log)
      end

      record
    end
  end
end
