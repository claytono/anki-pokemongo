#!/usr/bin/ruby

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'json'
require 'pp'
require 'cli'
require 'pokemon'

CLI.new(ARGV).run