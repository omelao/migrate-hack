Gem::Specification.new do |spec|
  spec.name          = 'migrate-hack'
  spec.authors       = ['Carlos Zillner']
  spec.email         = ['carlos@function.ws']
  spec.version       = '0.1.3'

  spec.summary       = 'Runs old migrations without conflicts'
  spec.description = <<~DESC
    Ideal for deterministic pipelines, CI/CD, or containers that apply migrations step by step.\n
    --------------------------------\n
    ⚠️ Warning: This gem modifies the files in the repository where it is executed according to git history, but then restores everything to normal.
    Do not run it on servers that are actively serving the application.
    Run it in parallel.\n
  DESC

  spec.homepage      = 'https://rubygems.org/gems/migrate-hack'
  spec.license       = 'MIT'

  spec.files         = Dir['bin/*']
  spec.executables   = ["migrate-hack"]
  spec.metadata    = { 'source_code_uri' => 'https://github.com/omelao/migrate-hack' }
  spec.required_ruby_version = '>= 2.7.0'
end
