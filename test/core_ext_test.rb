require File.expand_path('../test_helper', __FILE__)

module CoreExtSpecs
  class Foo
    class Bar; end
  end
  
  class Baz; end
end

describe "Module" do
  it "should try to retrieve a constant by the full modulized name of the mod it’s called on" do
    # ActiveSupport::Dependencies raises an ArgumentError instead of NameError... :(
    lambda { CoreExtSpecs::Foo.modulized_mod_get('Baz') }.should.raise ArgumentError
    CoreExtSpecs::Foo.modulized_mod_get('Bar').should.be CoreExtSpecs::Foo::Bar
  end
end