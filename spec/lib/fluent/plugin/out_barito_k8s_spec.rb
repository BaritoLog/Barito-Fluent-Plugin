require 'spec_helper'

describe 'Fluent::BaritoK8sOutput' do

  describe '.produce_url' do
    it do
      k8s_labels = {
        Fluent::BaritoK8sOutput::LABEL_PRODUCE_URL => 'https://localhost:5000/produce/sometopic'
      }

      out = Fluent::BaritoK8sOutput.new
      url = out.produce_url(k8s_labels)
      expect(url).to eq 'https://localhost:5000/produce/sometopic'
    end

  end

  describe '.application_secret' do
    it do
      out = Fluent::BaritoK8sOutput.new

      k8s_labels = {
        Fluent::BaritoK8sOutput::LABEL_APP_SECRET => 'some_secret'
      }
      secret = out.application_secret(k8s_labels)
      expect(secret).to eq 'some_secret'
    end
  end

  describe '.application_group_secret' do
    it do
      out = Fluent::BaritoK8sOutput.new

      k8s_labels = {
        Fluent::BaritoK8sOutput::LABEL_APP_GROUP_SECRET => 'some_secret'
      }
      secret = out.application_group_secret(k8s_labels)
      expect(secret).to eq 'some_secret'
    end
  end

  describe '.application_name' do
    it do
      out = Fluent::BaritoK8sOutput.new

      k8s_labels = {
        Fluent::BaritoK8sOutput::LABEL_APP_NAME => 'some_name'
      }
      app_name = out.application_name(k8s_labels)
      expect(app_name).to eq 'some_name'
    end
  end

  describe '.merge_log_attribute' do
    it do
      out = Fluent::BaritoK8sOutput.new

      record = { "log" => "{\"some_attr\":\"info\"}", "other_attr" => "other_value"}
      new_record = out.merge_log_attribute(record)

      expect(new_record['some_attr']).to eq("info")
      expect(new_record['other_attr']).to eq("other_value")
    end
  end

  describe '.clean_attribute' do
    it do
      out = Fluent::BaritoK8sOutput.new

      record = {"kubernetes" => {"some_attr" => "some_value"}, "docker" => "docker_value", "attr" => "some_value"}
      new_record = out.clean_attribute(record)

      expect(new_record['kubernetes']).to be_nil
      expect(new_record['docker']).to be_nil
      expect(new_record['attr']).to eq("some_value")
    end
  end

end
