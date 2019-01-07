#!/usr/bin/ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'cli'

CLI.new(ARGV).run