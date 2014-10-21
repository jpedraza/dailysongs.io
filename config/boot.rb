ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile", __FILE__)

if File.exist?(ENV["BUNDLE_GEMFILE"])
  require "bundler/setup"
end
