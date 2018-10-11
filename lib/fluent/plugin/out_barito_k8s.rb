require 'fluent/output'
require 'rest-client'
require_relative 'barito_timber'
require_relative 'barito_client_trail'

module Fluent
  class BaritoK8sOutput < BufferedOutput

    PLUGIN_NAME = 'barito_k8s'
    LABEL_APP_SECRET = 'barito.applicationSecret'
    LABEL_APP_GROUP_SECRET = 'barito.appGroupSecret'
    LABEL_APP_NAME = 'barito.appName'
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

        # Kubernetes annotations
        k8s_metadata = record['kubernetes']
        params = k8s_metadata['annotations']

        # Skip record if no annotations found
        next if params.nil?
        url = produce_url(params)
        app_secret = application_secret(params)
        app_group_secret = app_group_secret(params)
        app_name = app_name(params)

        next if url.nil?

        if app_secret.nil?
          next if app_group_secret.nil? or app_name.nil?
          header = {
            content_type: :json,
            'X-App-Group-Secret' => app_group_secret,
            'App-Name' => app_name
          }
        else
          header = {content_type: :json, 'X-App-Secret' => app_secret}
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

        RestClient.post url, new_timber.to_json, header
      end
    end

    def produce_url(params)
      params[LABEL_PRODUCE_URL]
    end

    def application_secret(params)
      params[LABEL_APP_SECRET]
    end

    def app_group_secret(params)
      params[LABEL_APP_GROUP_SECRET]
    end

    def app_name(params)
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
