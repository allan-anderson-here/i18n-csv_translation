# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'i18n/csv_translation/version'

Gem::Specification.new do |spec|
  spec.name          = 'i18n-csv_translation'
  spec.version       = I18n::CsvTranslation::VERSION
  spec.authors       = ['Sebastian Welther']
  spec.email         = ['sebastian@welther.de']

  spec.summary       = 'Exports all i18n keys and values of one locale into one CSV and imports it back as new locale.'
  spec.description   = 'Ever needed to add a new locale to an existing (Rails) project with dozens of .yml files? Too afraid to give all files to the customer or translation service and hope they do not mess up the YAML format? This gem allows you to export all i18n keys and values to one CSV file. With this the values can be easily translated and later reimported into your project. The new translations are saved in a filename similar to the original one (only the locale is replaced).'
  spec.homepage      = 'https://github.com/swelther/i18n-csv_translation'
  spec.license       = 'MIT'

  spec.cert_chain  = ['certs/swelther.pem']
  spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem') if $PROGRAM_NAME =~ /gem\z/

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_dependency 'deep_merge', '~> 1.1'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_development_dependency 'pry', '~> 0.10'
end
