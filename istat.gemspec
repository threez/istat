# -*- encoding: utf-8 -*-
$:.push('lib')
require "istat/version"

Gem::Specification.new do |s|
  s.name     = "istat"
  s.version  = Istat::VERSION.dup
  s.date     = "2011-04-29"
  s.summary  = "an istat client library for ruby"
  s.email    = "vilandgr+github@googlemail.com"
  s.homepage = "https://github.com/threez/istat"
  s.authors  = ['Vincent Landgaf']
  
  s.description = <<-EOF
an istat client library for ruby
EOF
  
  dependencies = [
    # Examples:
    # [:runtime,     "rack",  "~> 1.1"],
    [:development, "rspec", "~> 2.1"],
  ]
  
  s.files         = Dir['**/*']
  s.test_files    = Dir['spec/**/*']
  s.executables   = Dir['bin/*'].map { |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  
  ## Make sure you can build the gem on older versions of RubyGems too:
  s.rubygems_version = "1.6.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.specification_version = 3 if s.respond_to? :specification_version
  
  dependencies.each do |type, name, version|
    if s.respond_to?("add_#{type}_dependency")
      s.send("add_#{type}_dependency", name, version)
    else
      s.add_dependency(name, version)
    end
  end
end
