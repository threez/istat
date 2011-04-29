# istat Client

It is a client for the istatd service from [bjango](http://bjango.com/iphone/istat/). The Protocol has implementations for
Mac and [Linux/Solaris/FreeBSD](https://github.com/tiwilliam/istatd). Therefore I implemented a simple client in ruby.

## Installation

Just install the gem using:

    sudo gem install istat

## Usage

Connect to an istat server with this sample code:

    client = Istat::Client.new("example.com", 5109, "secret")
    client.start do |session|
      begin
        response = session.fetch
        p response.cpu
        sleep 1
      end while true
    end
    
## Contribute

Write tests, fork, write issues, ...

## Test

If you want to hack on the client, here is the way to start the tests:

    TEST_SERVER=istat://any:secret@example.com:5109/ rspec spec
    
Replace *secret*, and *example.com* with your code and host.
    
## License

Copyright (c) 2011 Vincent Landgraf

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
