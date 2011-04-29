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
    attr_accessor :connection_frame
    
    # create a new istat client instance
    def initialize(host, port, passwd, logger = nil)
      @host, @port, @passwd, @logger = host, port, passwd, logger
      @request_id = 1
    end
    
    # starts a session on the remote machine
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
    def connect!
      @logger.info "Connect to #{@host}:#{@port}" if @logger
      @socket = TCPSocket.new(@host, @port)
      true
    end
    
    # authenticate using the password, that was passed during initialization
    def authenticate!
      @logger.info "Authenticate using password #{'*' * @passwd.size}" if @logger
      send Istat::Frames::AuthenticationRequest.new(@passwd)
      response = Istat::Frames::AuthenticationResponse.new(receive)
      response.ready?
    end
    
    # checks if the host has the istat service active
    def online?
      @logger.info "Test the connection" if @logger
      send Istat::Frames::ConnectionTestRequest.new
      response = Istat::Frames::ConnectionTestResponse.new(receive)
      response.success?
    end
    
    # closes the connection
    def close!
      @logger.info "Close the connection" if @logger
      @socket.close
      true
    end
    
    # register to the remote server using the source hostname and a uuid
    def register!(hostname = nil, duuid = nil)
      hostname ||= Socket.gethostname
      duuid ||= Istat::Utils.uuid
      @logger.info "Register using hostname '#{hostname}' and duuid '#{duuid}'" if @logger
      send Istat::Frames::RegisterRequest.new(hostname, duuid)
      @connection_frame = Istat::Frames::RegisterResponse.new(receive)
    end
    
    # fetch data from the remote server
    def fetch
      @logger.info("Fetch measurements with request_id #{@request_id}")
      send Istat::Frames::MeasurementRequest.new(@request_id)
      @request_id += 1 # increment for next request
      Istat::Frames::MeasurementResponse.new(receive)
    end
    
  protected
    
    # send a frame
    def send(frame)
      @logger.debug "Send: #{frame.to_s}" if @logger
      @socket.send frame.to_s, 0
    end
    
    # receive data for a frame
    def receive
      data = ""
      begin
        data << @socket.recv(1024)
      end while !data.include?("</isr>")
      @logger.debug "Recieved: #{data}" if @logger
      data
    end
  end
end
