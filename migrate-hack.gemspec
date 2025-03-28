Gem::Specification.new do |spec|
  spec.name          = 'migrate-hack'
  spec.authors       = ['Carlos Zillner']
  spec.email         = ['carlos@function.ws']
  spec.version       = '0.1.8'

  spec.summary       = 'Runs old migrations without conflicts'
  spec.description = <<~EOF
    This gem checks out previous commits to run migrations, then restores everything back to normal.\n
  EOF

  spec.homepage      = 'https://rubygems.org/gems/migrate-hack'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*']
  spec.executables   = ["migrate-hack"]
  spec.metadata    = { 
    'source_code_uri' => 'https://github.com/omelao/migrate-hack', 
    'changelog_uri' => 'https://github.com/omelao/migrate-hack/blob/main/CHANGELOG.md' 
  }
  spec.required_ruby_version = '>= 2.7.0'
end
