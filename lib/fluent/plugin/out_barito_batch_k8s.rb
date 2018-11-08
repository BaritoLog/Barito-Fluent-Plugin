require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoBatchK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_batch_k8s'
    LABEL_APP_SECRET = 'barito.applicationSecret'
    LABEL_APP_GROUP_SECRET = 'barito.applicationGroupSecret'
    LABEL_APP_NAME = 'barito.applicationName'
    LABEL_PRODUCE_URL = 'barito.produceUrl'
    KEY_SEPARATOR = '|'

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
      array_of_data = {}
      chunk.msgpack_each do |tag, time, record|

        # Kubernetes annotations
        k8s_metadata = record['kubernetes']
        params = k8s_metadata['annotations']

        # Skip record if no annotations found
        next if params.nil?
        url = produce_url(params)
        app_secret = application_secret(params)
        app_group_secret = application_group_secret(params)
        app_name = application_name(params)

        next if url.nil?

        if app_secret.nil?
          next if app_group_secret.nil? or app_name.nil?
          key = "#{app_group_secret}#{KEY_SEPARATOR}#{app_name}"
        else
          key = app_secret
        end

        if array_of_data[key].nil?
          array_of_data[key] = {
              'url' => url,
              'app_group_secret' => app_group_secret,
              'app_name' => app_name,
              'app_secret' => app_secret,
              'items' => []
          }
        end

        record = clean_attribute(record)
        trail = Fluent::Plugin::ClientTrail.new(true)
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, time, record, trail)
        new_timber = merge_log_attribute(timber)

        # Add kubernetes information
        new_timber['k8s_metadata'] = {
          'pod_name' => k8s_metadata['pod_name'],
          'namespace_name' => k8s_metadata['namespace_name'],
          'container_name' => k8s_metadata['container_name'],
          'host' => k8s_metadata['host']
        }

        array_of_data[key]['items'] << new_timber
      end

      return if array_of_data.nil?

      array_of_data.each do |key, val|
        url = val['url']
        items = val['items']
        if key.include? KEY_SEPARATOR
          header = {
              content_type: :json,
              'X-App-Group-Secret' => val['app_group_secret'],
              'X-App-Name' => val['app_name']
          }
        else
          header = {
              content_type: :json,
              'X-App-Secret' => val['app_secret']
          }
        end

        response = RestClient.post url, items.to_json, header
      end
    end

    def produce_url(params)
      params[LABEL_PRODUCE_URL]
    end

    def application_secret(params)
      params[LABEL_APP_SECRET]
    end

    def application_group_secret(params)
      params[LABEL_APP_GROUP_SECRET]
    end

    def application_name(params)
      params[LABEL_APP_NAME]
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
