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
  module Frames
    # authenticate with passwd
    class AuthenticationRequest 
      # create a new authentication resquest frame with the passed code/password
      # @param [String] password the password to use for authentication
      def initialize(password)
        @password = password
      end
      
      # just returns the password, the frame has no header or container
      # @return [String] the password
      def to_s
        @password
      end
    end
    
    class AuthenticationResponse < Response
      READY  = "ready".freeze
      REJECT = "athrej".freeze

      # check if he authentication was successful
      # @return [Boolean] true if authentication is successful
      def ready?
        if val = @root.attributes[READY]
          val.to_i == 1
        else
          false
        end
      end

      # check if he authentication was rejected
      # @return [Boolean] true if authentication is rejected
      def rejected?
        if val = @root.attributes[REJECT]
          val.to_i == 1
        else
          false
        end
      end
    end
  end
end
