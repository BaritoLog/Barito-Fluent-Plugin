require 'fluent/output'
require_relative 'barito_timber'
require_relative 'barito_client_trail'
require_relative 'barito_transport'

module Fluent
  class BaritoDynamicAppBatchK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_dynamic_app_batch_k8s'

    Fluent::Plugin.register_output(PLUGIN_NAME, self)

    config_param :application_name_format, :string, :default => nil
    config_param :application_group_secret, :string, :default => nil
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
      data = {}

      transport = Fluent::Plugin::BaritoTransport.new(@produce_url, log)
      chunk.msgpack_each do |tag, time, record|

        # generate application name
        if @application_name_format.nil?
          return
        end

        application_name = expand_application_name_format(record)

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

        if data[application_name].nil?
          data[application_name] = { 'items' => [] }
        end
        data[application_name]['items'] << new_timber
      end

      data.each do |application_name, record|
        header = {
          content_type: :json,
          'X-App-Group-Secret' => @application_group_secret,
          'X-App-Name' => application_name
        }
        transport.send_compressed(record, header)
      end
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

    private

    def expand_application_name_format(record)
      application_name = @application_name_format.dup

      # Regular expression to match placeholders like ${record["key1"]["key2"]}
      placeholder_regex = /\${record(\["[^"]*"\])+}/

      application_name.gsub!(placeholder_regex) do |placeholder|
        # Extract keys from the placeholder
        keys = placeholder.scan(/\["([^"]*)"\]/).flatten
        # Retrieve the value from the record hash
        value = get_nested_value(record, keys)
        value.to_s
      end

      application_name
    end

    # Retrieve nested value from record using array of keys
    def get_nested_value(record, keys)
      keys.reduce(record) do |acc, key|
        if acc.is_a?(Hash) && acc.key?(key)
          acc[key]
        else
          # Key not found; return nil to stop further traversal
          return nil
        end
      end
    end

  end
end
