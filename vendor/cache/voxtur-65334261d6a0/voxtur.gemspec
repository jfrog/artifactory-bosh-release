# -*- encoding: utf-8 -*-
# stub: voxtur 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "voxtur"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://cf-london@git.fury.io" } if s.respond_to? :metadata=
  s.require_paths = ["lib"]
  s.authors = ["Will Pragnell"]
  s.date = "2015-06-03"
  s.email = ["wpragnell@pivotallabs.com"]
  s.executables = ["voxtur", "voxtur_utgafa"]
  s.files = ["bin/voxtur", "bin/voxtur_utgafa", "lib/voxtur", "lib/voxtur.rb", "lib/voxtur/command.rb", "lib/voxtur/metadata_updater.rb", "lib/voxtur/release_info_extractor.rb", "lib/voxtur/update_product_version_command.rb", "lib/voxtur/version.rb"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Updates Ops Manager product metadata from a BOSH release."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.7.2"])
      s.add_development_dependency(%q<gemfury>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<gem-release>, ["~> 0.7.3"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.7.2"])
      s.add_dependency(%q<gemfury>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<gem-release>, ["~> 0.7.3"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.7.2"])
    s.add_dependency(%q<gemfury>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<gem-release>, ["~> 0.7.3"])
  end
end
