#!/usr/bin/env ruby
# frozen_string_literal: true

project_root = File.expand_path('..', __dir__)

master = nil
dir = project_root
loop do
  candidate = File.join(dir, 'infra', 'SaneProcess', 'scripts', 'SaneMaster.rb')
  if File.exist?(candidate)
    master = candidate
    break
  end

  parent = File.dirname(dir)
  break if parent == dir

  dir = parent
end

home_candidate = File.expand_path('~/SaneApps/infra/SaneProcess/scripts/SaneMaster.rb')
master ||= home_candidate if File.exist?(home_candidate)

unless master && File.exist?(master)
  warn "SaneMaster not found at #{master}"
  exit 1
end

exec('ruby', master, *ARGV)
