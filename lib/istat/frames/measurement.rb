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
    class MeasurementRequest < Request
      RID      = :rid
      CPU      = :c
      NETWORK  = :n
      MEMORY   = :m
      LOAD     = :lo
      TEMP     = :t  # qnap only
      FAN      = :f
      UPTIME   = :u
      DISK     = :d

      # create a new request based on the requested id. The default is to
      # request only the last values (since -1)
      def initialize(rid, since = -1)
        super create([RID,     rid],
                     [CPU,     since],
                     [NETWORK, since],
                     [MEMORY,  since],
                     [LOAD,    since],
                     [TEMP,    since],
                     [FAN,     since],
                     [UPTIME,  since],
                     [DISK,    since])
      end
    end
    
    class MeasurementResponse < Response
      # returns true if there is a cpu section in the frame
      def cpu?
        has_node? :CPU
      end

      # returns the structure that is held in the 
      def cpu
        entires_for(:CPU) do |element, attributes|
          { 
            :id     => attributes["id"].to_i,
            :user   => attributes["u"].to_i,
            :system => attributes["s"].to_i,
            :nice   => attributes["n"].to_i
          }
        end
      end

      # returns true if there is a network section in the frame
      def network?
        has_node? :NET
      end

      # returns the network data
      def network
        interfaces = { 1 => [] }
        entires_for(:NET) do |element, attributes|
          interfaces[1] << { 
            :id => attributes["id"].to_i,
            :d  => attributes["d"].to_i,
            :u  => attributes["u"].to_i,
            :t  => attributes["t"].to_i
          }
        end
        interfaces
      end

      # returns true if there is a memory section in the frame
      def memory?
        has_node? :MEM
      end
      
      # returns the memory information
      def memory
        attributes = @root.elements["MEM"].attributes
        {
          :wired => attributes["w"].to_i,
          :active => attributes["a"].to_i,
          :inactive => attributes["i"].to_i,
          :free => attributes["f"].to_i,
          :total => attributes["t"].to_i,
          :swap_used => attributes["su"].to_i,
          :swap_total => attributes["st"].to_i,
          :page_ins => attributes["pi"].to_i,
          :page_outs => attributes["po"].to_i
        }
      end

      # returns true if there is a load section in the frame
      def load?
        has_node? :LOAD
      end
      
      # returns the load of the system
      def load
        attributes = @root.elements["LOAD"].attributes
        [attributes["one"].to_f, attributes["fv"].to_f, attributes["ff"].to_f]
      end

      # returns true if there is a temps section in the frame
      def temps?
        has_node? :TEMPS
      end
      
      # returns the temps
      def temps
        temps = []
        entires_for(:TEMPS) do |element, attributes|
          temps[attributes["i"].to_i] = attributes["t"].to_i
        end
        temps
      end

      # returns true if there is a fan section in the frame
      def fans?
        has_node? :FANS
      end
      
      # returns the fans
      def fans
        fans = []
        entires_for(:FANS) do |element, attributes|
          fans[attributes["i"].to_i] = attributes["s"].to_i
        end
        fans
      end

      # returns true if there is a uptime section in the frame
      def uptime?
        has_node? :UPT
      end
      
      # reuturns the uptime of the system
      def uptime
        Time.now - @root.elements["UPT"].attributes["u"].to_i
      end

      # returns true if there is a disks section in the frame
      def disks?
        has_node? :DISKS
      end
      
      # returns all disks of the system
      def disks
        entires_for(:DISKS) do |element, attributes|
          { 
            :label          => attributes["n"],
            :uuid           => attributes["uuid"],
            :free           => attributes["f"].to_i,
            :percent_used   => attributes["p"].to_f
          }
        end
      end

    protected

      # returns true is a node is available
      def has_node?(name)
        !@root.elements["#{name}"].nil?
      end

      # yields over the elements of a path
      def entires_for(name, &block)
        entries = []
        @root.elements["#{name}"].map do |element|
          unless element.is_a? REXML::Text
            entries << block.call(element, element.attributes)
          end
        end
        entries
      end
    end
  end
end
