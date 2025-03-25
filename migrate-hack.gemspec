Gem::Specification.new do |spec|
  spec.name          = 'migrate-hack'
  spec.authors       = ['Carlos Zillner']
  spec.email         = ['carlos@function.ws']
  spec.version       = '0.1.0'

  spec.summary       = 'Runs old migrations without conflicts'
  spec.description   = 'Ideal for deterministic pipelines, CI/CD, or containers that apply migrations step by step.'
  spec.homepage      = 'https://rubygems.org/gems/migrate-hack'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*']
  spec.metadata    = { 'source_code_uri' => 'https://github.com/omelao/migrate-hack' }
  spec.required_ruby_version = '>= 2.7.0'
end
