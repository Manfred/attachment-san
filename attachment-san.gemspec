Gem::Specification.new do |s|
  s.name = %q{attachment-san}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran", "Manfred Stienstra"]
  s.date = %q{2014-06-03}
  s.description = %q{Rails plugin for easy and rich attachment manipulation.}
  s.email = ["eloy@fngtps.com", "manfred@fngtps.com"]
  s.extra_rdoc_files = ["LICENSE"]
  s.files = [
    "LICENSE",
    "README.md",
    "TODO",
    "VERSION"
  ] + Dir.glob('lib/**/*.rb')
  s.homepage = %q{http://github.com/Fingertips/attachment-san}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Rails plugin for easy and rich attachment manipulation. It allows you to treat attachments as associations with file variants.}
  s.license = 'MIT'

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

