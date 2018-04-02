require 'spec_helper'

describe 'Fluent::BaritoOutput' do
  
  describe 'create_timber' do
    it 'is valid parameter' do
      curr_time = Time.parse('2018-01-31 12:25:36')
      
      Timecop.freeze(curr_time) do
        output = Fluent::BaritoOutput.new
        tag = "some_tag"
        time = Time.parse('2018-01-31 12:22:26')
        record = {"message" => "some_message"}
        
        timber = output.create_timber(tag, time, record)
        expect(timber.tag).to eq(tag)
        expect(timber.timestamp).to eq(time)
        expect(timber.message).to eq("some_message")
        
        expect(timber.client_trail).to_not be_nil
        expect(timber.client_trail.is_k8s).to be false
        expect(timber.client_trail.sent_at).to eq(curr_time)
      end
    end
    
    it 'using current timestamp if timber.timestamp nil' do
      time = Time.parse('2018-01-31 12:22:26')
      
      Timecop.freeze(time) do
        output = Fluent::BaritoOutput.new
        
        record = {"message" => "some_message"}
        timber = output.create_timber("some_tag", nil, record)
        
        expect(timber.timestamp).to eq(time)
        expect(timber.client_trail.hints).to include(Fluent::BaritoOutput::HINTS_NO_TIMESTAMP)
      end
    end
    
    it 'using whole record if record[MESSAGE_KEY] emtpy' do
      output = Fluent::BaritoOutput.new
      
      timber = output.create_timber("some_tag", nil, "invalid_message")
      expect(timber.message).to eq("invalid_message")
      expect(timber.client_trail.hints).to include(Fluent::BaritoOutput::HINTS_NO_MESSAGE)
    end
  end
  
end
