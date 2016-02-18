# .gemspec
Gem::Specification.new do |s|
  s.name        = 'bel-tsv-translator'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'A TAB-separated translator for BEL Nanopubs.'
  s.description = 'This translator provides read/write functionality for BEL Nanopubs stored in TAB-separated files. This translator is intended to integrate with bel.rb.'
  s.authors     = ['Your Name']
  s.email       = 'your@email.com'
  s.files       = [
    'lib/bel/translator/plugins/tsv.rb',
    'lib/bel/translator/plugins/tsv/translator.rb'
  ]
  s.homepage    = 'https://rubygems.org/gems/bel.rb-tsv-translator'

  # Dependency on the bel.rb library.
  s.add_runtime_dependency 'bel', '~> 0.5'
end
