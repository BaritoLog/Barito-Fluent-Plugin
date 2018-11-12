require 'rest-client'

class Fluent::Plugin::BaritoTransport

  attr_accessor :produce_url, :logger

  def initialize(produce_url, logger)
    @produce_url = produce_url
    @logger = logger
  end

  def send(timber, header)
    begin
      RestClient.post @produce_url, timber.to_json, header
    rescue Exception => e
      @logger.error [e.message, e.response, header].join(', ')
    end
  end

end