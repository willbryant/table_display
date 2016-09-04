# -*- encoding: utf-8 -*-
require File.expand_path('../lib/table_display/version', __FILE__)

spec = Gem::Specification.new do |gem|
  gem.name         = 'table_display'
  gem.version      = TableDisplay::VERSION
  gem.summary      = "Adds support for displaying your ActiveRecord tables, named scopes, collections, or plain arrays in a table view when working in script/console, shell, or email template."
  gem.description  = <<-EOF
Adds support for displaying your ActiveRecord tables, named scopes, collections, or
plain arrays in a table view when working in rails console, shell, or email template.

Enumerable#to_table_display returns the printable strings; Object#pt calls #to_table_display on its
first argument and puts out the result.

Columns you haven't loaded (eg. from using :select) are omitted, and derived/calculated
columns (eg. again, from using :select) are added.

Both #to_table_display and Object#pt methods take :only, :except, and :methods which work like
the #to_xml method to change what attributes/methods are output.

The normal output uses #inspect on the data values to make them printable, so you can
see what type the values had.  When that's inconvenient or you'd prefer direct display,
you can pass the option :inspect => false to disable inspection.
EOF
  gem.has_rdoc     = false
  gem.author       = "Will Bryant"
  gem.email        = "will.bryant@gmail.com"
  gem.homepage     = "http://github.com/willbryant/table_display"
  
  gem.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files        = `git ls-files`.split("\n")
  gem.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.require_path = "lib"
  
  gem.add_development_dependency "rake"
  gem.add_development_dependency "sqlite3"
  gem.add_development_dependency "activerecord"
  gem.add_development_dependency "test-unit"
end
