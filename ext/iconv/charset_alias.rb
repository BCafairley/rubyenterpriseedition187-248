#! /usr/bin/ruby
require 'rbconfig'

# http://www.ctan.org/tex-archive/macros/texinfo/texinfo/intl/config.charset
# Fri, 30 May 2003 00:09:00 GMT'

OS = Config::CONFIG["target"]
SHELL = Config::CONFIG['SHELL']

def charset_alias(config_charset, mapfile, target = OS)
  map = {}
  comments = []
  IO.foreach("|#{SHELL} #{config_charset} #{target}") do |list|
    next comments << list if /^\#/ =~ list
    next unless /^(\S+)\s+(\S+)$/ =~ list
    sys, can = $1, $2
    next if sys == can
    next if can.downcase! and sys == can
    map[can] = sys
  end
  case target
  when /linux|-gnu/
    map.delete('ascii')
  when /cygwin/
    # get rid of tilde/yen problem.
    map['shift_jis'] = 'cp932'
  end
  open(mapfile, "w") do |f|
    f.puts("require 'iconv.so'")
    f.puts
    f.puts(comments)
    f.puts("class Iconv")
    map.each {|can, sys| f.puts("  charset_map['#{can}'.freeze] = '#{sys}'.freeze")}
    f.puts("end")
  end
end

(2..3) === ARGV.size or abort "usage: #$0 config.status map.rb [target]"
charset_alias(*ARGV)
