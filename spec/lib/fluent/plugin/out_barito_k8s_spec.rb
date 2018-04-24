require 'spec_helper'

describe 'Fluent::BaritoK8sOutput' do
  
  describe '.produce_url' do
    it do
      k8s_labels = {
        Fluent::BaritoK8sOutput::LABEL_PRODUCE_HOST => 'localhost',
        Fluent::BaritoK8sOutput::LABEL_PRODUCE_PORT => '5000',
        Fluent::BaritoK8sOutput::LABEL_PRODUCE_TOPIC => 'sometopic'
      }
      
      out1 = Fluent::BaritoK8sOutput.new
      out1.use_https = true
      url = out1.produce_url(k8s_labels)
      expect(url).to eq 'https://localhost:5000/produce/sometopic'
      
      out2 = Fluent::BaritoK8sOutput.new
      out2.use_https = false
      url = out2.produce_url(k8s_labels)
      expect(url).to eq 'http://localhost:5000/produce/sometopic'
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
  
end
