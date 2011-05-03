require "socket"

# Copyright (c) 2011 Vincent Landgraf
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
module Istat
  class Client
    class WrongPasswordException < Exception; end
    class NoServiceException < Exception; end
    class RegisterException < Exception; end
    
    # the frame that was send from the server after registration
    attr_accessor :connection_frame
    
    # create a new istat client instance
    # @param host [String] the hostname of the remote istat server
    # @param port [String] the port of the istat server usually 5109
    # @param passwd [String] the passwd or code to access the server
    # @param logger [optional Logger] a logger that will log all actions on the client
    # @example
    #   @client = Istat::Client.new("example.com", 5109, "00000")
    #
    def initialize(host, port, passwd, logger = nil)
      @host, @port, @passwd, @logger = host, port, passwd, logger
      @request_id = 1
    end
    
    # starts a session on the remote machine and yields it to the passed block.
    # @yield [Istat::Client] the remote session
    # @example
    #   @client = Istat::Client.new("example.com", 5109, "00000")
    #   @client.start do |session|
    #     # work with the session
    #   end
    #
    def start
      connect!
      if online?
        if register!
          if authenticate!
            yield(self)
          else
            raise WrongPasswordException.new("Wrong password/code!")
          end
        else
          raise RegisterException.new("Can't register to the service")
        end
      else
        raise NoServiceException.new("Service is not available")
      end
      close!
    end
    
    # connect to the remote server
    # @return [Boolean] true is the connection was successfull
    def connect!
      @logger.info "Connect to #{@host}:#{@port}" if @logger
      @socket = TCPSocket.new(@host, @port)
      true
    end
    
    # authenticate using the password, that was passed during initialization
    # @note must be connected and registered to the remote machine
    # @return [Boolean] true on success
    def authenticate!
      @logger.info "Authenticate using password #{'*' * @passwd.size}" if @logger
      send Istat::Frames::AuthenticationRequest.new(@passwd)
      response = Istat::Frames::AuthenticationResponse.new(receive)
      response.ready?
    end
    
    # checks if the host has the istat service active
    # @note must be connected to the remote machine
    # @return true on success
    def online?
      @logger.info "Test the connection" if @logger
      send Istat::Frames::ConnectionTestRequest.new
      response = Istat::Frames::ConnectionTestResponse.new(receive)
      response.success?
    end
    
    # closes the connection
    # @return true on success
    def close!
      @logger.info "Close the connection" if @logger
      @socket.close
      true
    end
    
    # register to the remote server using the source hostname and a uuid. If
    # no values are passed, they will be fetched usind system methods. (Socket.gethostname)
    # @note must be connected before this action should be called
    # @param [optional, String] hostname the hostname for the registration (e.g. example.com)
    # @param [optional, String] duuid the uuid for the registration
    def register!(hostname = nil, duuid = nil)
      hostname ||= Socket.gethostname
      duuid ||= Istat::Utils.uuid
      @logger.info "Register using hostname '#{hostname}' and duuid '#{duuid}'" if @logger
      send Istat::Frames::RegisterRequest.new(hostname, duuid)
      @connection_frame = Istat::Frames::RegisterResponse.new(receive)
    end
    
    # fetch data from the remote server
    # @param [Integer|Time] since size of the requested history (-1 last)
    # @return [Istat::Frames::MeasurementResponse] the fetched result
    # @example
    #   @client = Istat::Client.new("example.com", 5109, "00000")
    #   @client.start do |session|
    #     response = session.fetch
    #     response.load # => [0.54, 0.59, 0.65]
    #   end
    #
    def fetch(since = -1)
      @logger.info("Fetch measurements with request_id #{@request_id}")
      send Istat::Frames::MeasurementRequest.new(@request_id, since)
      @request_id += 1 # increment for next request
      Istat::Frames::MeasurementResponse.new(receive)
    end
    
    # fetch all data available on the remote server
    # @return [Istat::Frames::MeasurementResponse] the fetched result
    # @see #fetch
    def fetch_all
      fetch(-2)
    end
    
  protected
    
    # send a frame to the remote system (istatd)
    # @note will use the *to_s* method to serialize the frame on the wire
    # @param [Istat::Frame::Request] the frame to send
    # @return [Integer] number of bytes send
    def send(frame)
      @logger.debug "Send: #{frame.to_s}" if @logger
      @socket.send frame.to_s, 0
    end
    
    # receive data for a frame from the remote system (istatd)
    # @return [String] the xml stream that was send from istatd
    def receive
      data = ""
      data << @socket.recv(1024) while !data.include?("</isr>")
      @logger.debug "Received: #{data}" if @logger
      data
    end
  end
end
