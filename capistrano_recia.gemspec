Gem::Specification.new do |s| 
  s.name = "capistrano_recia"
  s.description = "RECIA Capistrano Support"
  s.version = "0.0.3"
  s.author = "Esco-lan Team"
  s.email = "team@esco-lan.org"
  s.homepage = "https://github.com/RECIA/capistrano_recia"
  s.platform = Gem::Platform::RUBY
  s.summary = "Provides additionnal methods to capistrano like run_parent, run_filter_role_contained and run_filter_role_uncontained"
  s.files = Dir['lib/**/*.rb']
  s.require_path = "lib"
  s.extra_rdoc_files = ["README.rdoc","RELEASE.rdoc"]
  s.add_dependency('capistrano', '>= 2.11.2')
  s.add_dependency('capistrano_telnet', '>= 0.0.1')
  s.add_dependency('capistrano_supports', '>= 0.0.1')
  s.add_dependency('nagios_mklivestatus', '>= 0.0.11')
  s.add_dependency('keepass-password-generator', '>= 0.1.1')
  s.add_dependency('encrypted_strings', '>= 0.3.3')
end