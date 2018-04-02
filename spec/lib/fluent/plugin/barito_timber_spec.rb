require 'spec_helper'

describe 'Fluent::Plugin::Timber' do
  
  describe 'create_timber' do
    
    it 'is valid parameter' do
      trail = Fluent::Plugin::ClientTrail.new(true)
      
      tag = "some_tag"
      time = Time.parse('2018-01-31 12:22:26')
      record = {"message" => "some_message"}
      
      timber = Fluent::Plugin::Timber::create_timber(tag, time, record, trail)
      expect(timber.tag).to eq(tag)
      expect(timber.timestamp).to eq(time)
      expect(timber.message).to eq("some_message")
      expect(timber.client_trail).to eq(trail)
      
    end
    
    it 'using current timestamp if timber.timestamp nil' do
      time = Time.parse('2018-01-31 12:22:26')
      
      Timecop.freeze(time) do
        trail = Fluent::Plugin::ClientTrail.new(true)
        
        record = {"message" => "some_message"}
        timber = Fluent::Plugin::Timber::create_timber("some_tag", nil, record, trail)
        
        expect(timber.timestamp).to eq(time)
        expect(timber.client_trail.hints).to include(Fluent::Plugin::Timber::HINTS_NO_TIMESTAMP)
      end
    end
    
    it 'using whole record if record[MESSAGE_KEY] emtpy' do
      trail = Fluent::Plugin::ClientTrail.new(true)
      
      timber = Fluent::Plugin::Timber::create_timber("some_tag", nil, "invalid_message", trail)
      expect(timber.message).to eq("invalid_message")
      expect(timber.client_trail.hints).to include(Fluent::Plugin::Timber::HINTS_NO_MESSAGE)
    end
  end
  
end
