require 'rest-client'
require 'zlib'

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

  def send_compressed(timber, header)
    begin
      header['Content-Encoding'] = 'gzip'

      gz = Zlib::GzipWriter.new(StringIO.new)
      gz << timber.to_json
      RestClient.post @produce_url, gz.close.string, header
    rescue Exception => e
      puts(header)
      @logger.error [e.message, e.response, Hash[header.collect{|k,v| [k.to_s, v]}]].join(', ')
    end
  end
end