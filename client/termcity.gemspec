
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "termcity/version"

Gem::Specification.new do |spec|
  spec.name          = "termcity"
  spec.version       = Termcity::VERSION
  spec.authors       = ["Pete Kinnecom"]
  spec.email         = ["git@k7u7.com"]

  spec.summary       = %q{Terminal view of TeamCity}
  spec.description   = %q{See TeamCity build status for a branch in your terminal. Pipe it to grep or whatever. Get nicely formatted links if you use iTerm2.}
  # spec.homepage      = "none"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.files         = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
end
