#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path('../../..', __dir__)
master = File.join(root, 'infra', 'SaneProcess', 'scripts', 'SaneMaster.rb')

unless File.exist?(master)
  warn "SaneMaster not found at #{master}"
  exit 1
end

exec('ruby', master, *ARGV)
