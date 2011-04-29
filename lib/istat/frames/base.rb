require "rexml/document"

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
    class Base
      DOCTYPE = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>".freeze
    
      # creates a frame based on the passed xml string
      def initialize(xml_str)
        @doc = REXML::Document.new(xml_str)
        @root = @doc.root
      end
    
      # returns the serialized frame
      def to_s
        @doc.to_s
      end
    
    protected
    
      # create new frame based on the passed params
      def create(*params)
        xml = "#{DOCTYPE}<isr>"
        params.each { |key, value| xml << "<#{key}>#{value}</#{key}>" }
        xml << "</isr>"
        xml
      end  
    end
    
    class Request < Base;  end
    class Response < Base; end
  end
end
