require 'spec_helper'

describe 'Fluent::BaritoBatchDynamicAppK8sOutput' do
  before do
    @plugin = Fluent::BaritoDynamicAppBatchK8sOutput.new
    @plugin.instance_variable_set(:@application_name_format, 'clusterA-${record["kubernetes"]["namespace_name"]}-${record["kubernetes"]["labels"]["app_name"]}')
  end

  describe '.merge_log_attribute' do
    it do
      record = {
        "kubernetes" => {"some_attr" => "some_value"},
        "docker" => "docker_value",
        "log" => "{\"some_attr\": \"info\", \"other_attr\": \"other_value\"}"
      }
      new_record = @plugin.merge_log_attribute(record)

      expect(new_record['some_attr']).to eq("info")
      expect(new_record['other_attr']).to eq("other_value")
    end
  end

  describe '.clean_attribute' do
    it do
      record = {
        "kubernetes" => {"some_attr" => "some_value"},
        "docker" => "docker_value",
        "attr" => "some_value"
      }
      new_record = @plugin.clean_attribute(record)

      expect(new_record['kubernetes']).to be_nil
      expect(new_record['docker']).to be_nil
      expect(new_record['attr']).to eq("some_value")
    end
  end

  describe '#expand_application_name_format' do
    it 'expands the application name format with values from the record' do
      record = {
        'kubernetes' => {
          'namespace_name' => 'namespace1',
          'labels' => {
            'app_name' => 'app1'
          }
        }
      }

      expanded_name = @plugin.expand_application_name_format(record)
      expect(expanded_name).to eq('clusterA-namespace1-app1')
    end

    it 'returns the format string if no placeholders are present' do
      @plugin.instance_variable_set(:@application_name_format, 'static_name')
      record = {}

      expanded_name = @plugin.expand_application_name_format(record)
      expect(expanded_name).to eq('static_name')
    end

    it 'returns the format string with empty values if keys are missing in the record' do
      record = {
        'kubernetes' => {
          'namespace_name' => 'namespace1'
        }
      }

      expanded_name = @plugin.expand_application_name_format(record)
      expect(expanded_name).to eq('clusterA-namespace1-')
    end

    it 'returns nil if the format string is nil' do
      @plugin.instance_variable_set(:@application_name_format, "")
      record = {}

      expanded_name = @plugin.expand_application_name_format(record)
      expect(expanded_name).to be_empty
    end
  end

end
