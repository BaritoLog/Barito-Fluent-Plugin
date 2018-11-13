require 'spec_helper'
require 'fluent/engine'
require 'fluent/log'

describe 'Fluent::Plugin::BaritoTransport' do
  describe 'send' do
    context 'exception' do
      let(:user_agent) { 'Barito' }
      let(:log) { Fluent::Test::DummyLogDevice.new }
      let(:logger) { ServerEngine::DaemonLogger.new(log) }

      it 'produce log' do
        mock_host = 'localhost-not-exist'
        uri_string = "http://#{mock_host}/"
        stub_request(:post, uri_string).
            with(
                headers: {
                    'Accept'=> '*/*',
                    'Host'=> mock_host,
                    'User-Agent'=>user_agent
                }).
            to_return(status: 404, body: "not-exist", headers: {'User-Agent': user_agent })

        transport = Fluent::Plugin::BaritoTransport.new(uri_string, logger)
        expect(logger).to receive(:error).with("404 Not Found, not-exist, {:\"User-Agent\"=>\"#{user_agent}\"}")
        transport.send({},{'User-Agent': user_agent})
      end
    end
  end
end
