require 'spec_helper'

describe 'Fluent::BaritoBatchK8sOutput' do
  describe '.merge_log_attribute' do
    it do
      out = Fluent::BaritoBatchK8sOutput.new

      record = {
        "kubernetes" => {"some_attr" => "some_value"}, 
        "docker" => "docker_value", 
        "log" => "{\"some_attr\": \"info\", \"other_attr\": \"other_value\"}"
      }
      new_record = out.merge_log_attribute(record)

      expect(new_record['some_attr']).to eq("info")
      expect(new_record['other_attr']).to eq("other_value")
    end
  end

  describe '.clean_attribute' do
    it do
      out = Fluent::BaritoBatchK8sOutput.new

      record = {
        "kubernetes" => {"some_attr" => "some_value"},
        "docker" => "docker_value",
        "attr" => "some_value"
      }
      new_record = out.clean_attribute(record)

      expect(new_record['kubernetes']).to be_nil
      expect(new_record['docker']).to be_nil
      expect(new_record['attr']).to eq("some_value")
    end
  end

end
