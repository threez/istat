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
      # @param [Integer] rid the request identifier (increases)
      # @param [Integer] since the since field (-1 for last, or Time.now timestamp)
      def initialize(rid, since = -1)
        since = Time.now.to_i - since.to_i if since.is_a? Time
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

      # collect cpu data (can contain history)
      # @return [Array<Hash>] the cpu load and usage data
      # @example Result
      #   [
      #     { :id => 28388970, :user => 0, :system => 0, :nice => 0 },
      #     { :id => 28388971, :user => 0, :system => 0, :nice => 0 },
      #     { :id => 28388972, :user => 0, :system => 0, :nice => 0 },
      #     { :id => 28388973, :user => 0, :system => 0, :nice => 0 }
      #   ]
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

      # collects all network information over the interfaces (can contain history)
      # @return [Hash<Array<Hash>>] the network data for the interfaces
      # @example Result
      #   {
      #     1 => [
      #       { :id => 28388970, :d => 4177773, :u => 232278672, :t => 1304082088 },
      #       { :id => 28388971, :d => 4177773, :u => 232278672, :t => 1304082089 },
      #       { :id => 28388972, :d => 4177773, :u => 232278672, :t => 1304082090 },
      #       { :id => 28388973, :d => 4177773, :u => 232278672, :t => 1304082091 }
      #     ]
      #   }
      #
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
      
      # parse the memory informations
      # @return [Hash] the memory information
      # @example Result
      #   {
      #     :wired => 25938,
      #     :active => 27620,
      #     :inactive => 11664,
      #     :free => 7983,
      #     :total => 73207,
      #     :swap_used => 3,
      #     :swap_total => 36861,
      #     :page_ins => 0,
      #     :page_outs => 0
      #   }
      #
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
      
      # parse the load informations
      # @return [Array] the load of the system
      # @example Result
      #   [0.54, 0.60, 0.67]
      #
      def load
        attributes = @root.elements["LOAD"].attributes
        [attributes["one"].to_f, attributes["fv"].to_f, attributes["ff"].to_f]
      end

      # returns true if there is a temps section in the frame
      def temps?
        has_node? :TEMPS
      end
      
      # collect all temperature informations in order
      # @return [Array] the temps that are returned using the sensor modules
      # @example
      #   [30, 52, 29, 50, 30, 64, 61]
      #
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
      
      # collect all fan informations in order
      # @return [Array] containing all the fans
      # @example Result
      #   [1999]
      #
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
      
      # calculate the system uptime
      # @return [Time] the uptime orf the system
      # @example Result
      #   "Sat Apr 30 09:46:45 +0200 2011"
      #
      def uptime
        Time.now - @root.elements["UPT"].attributes["u"].to_i
      end

      # returns true if there is a disks section in the frame
      def disks?
        has_node? :DISKS
      end
      
      # collect all disk informations
      # @return [Array<Hash>] all disks of the system
      # @example Result
      #   [
      #     :label => "/", 
      #     :uuid => "/dev/vzfs",
      #     :free => 9226,
      #     :percent_used => 39.931
      #   ]
      #
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

      # returns true if a node is available
      # @api private
      def has_node?(name)
        !@root.elements["#{name}"].nil?
      end

      # yields over the elements of a path
      # @api private
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
