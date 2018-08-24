require 'spec_helper'

describe 'Fluent::Plugin::TimberFactory' do
  
  describe 'create_timber' do
    
    context 'message' do
      
      it 'is json' do
        trail = Fluent::Plugin::ClientTrail.new(true)
        tag = "some_tag"
        record = {'message' => '{"booking_id":1234,"foo":"bar"}'}
        
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, nil, record, trail)
        expect(timber['booking_id']).to eq(1234)
        expect(timber['foo']).to eq('bar')
      end
      
      it 'is quoted string' do
        trail = Fluent::Plugin::ClientTrail.new(true)
        tag = "some_tag"
        record = {'message' => '"something"'}
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, nil, record, trail)
        expect(timber['@message']).to eq('"something"')
      end
      
      it 'is not json' do
        trail = Fluent::Plugin::ClientTrail.new(true)
        tag = "some_tag"
        record = {"message" => "some_message"}
        
        timber = Fluent::Plugin::TimberFactory::create_timber(tag, nil, record, trail)
        expect(timber['tag']).to eq(tag)
        expect(timber['@message']).to eq("some_message")
        expect(timber['client_trail']).to eq(trail.to_hash)
      end  
      
      it 'has no message' do
        trail = Fluent::Plugin::ClientTrail.new(true)
        timber = Fluent::Plugin::TimberFactory::create_timber("some_tag", nil, "invalid_message", trail)
        expect(timber['@message']).to eq("invalid_message")
        expect(timber['client_trail']['hints']).to include(Fluent::Plugin::TimberFactory::HINTS_NO_MESSAGE)
      end
      
    end
    
    
    
  end
  
end
