Gem::Specification.new do |spec|
  spec.name          = 'migrate-hack'
  spec.authors       = ['Carlos Zillner']
  spec.email         = ['carlos@function.ws']
  spec.version       = '0.2.4'

  spec.summary       = 'Run any amount of migrations without conflicts'
  spec.description = <<~EOF
    Run any amount of migrations. migrate-hack fixes your migrations. This gem rewinds your commits to apply migrations safely, and then puts everything back the way it was. This fixes a bunch of common issues.\n
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
