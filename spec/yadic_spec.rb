require File.dirname(__FILE__)+'/../lib/yadic.rb'
include Yadic

describe Container do
  before { @c = Container.new }

  context "given a class" do
    before { @c.add(:foo, Foo) }
    
    it "instantiates the class with no arguments" do
      @c[:foo].should be_instance_of Foo
    end

    it "always returns the same instance" do
      @c[:foo].should equal @c[:foo]
    end
  end

  context "given an initializer" do
    it "returns the results of the initializer" do
      @c.add(:foo) { Foo.new }
      @c[:foo].should be_instance_of Foo
    end

    it "passes itself as a parameter to the initializer" do
      @c.add(:foo, Foo)
      @c.add(:bar) { |c| Bar.new(c[:foo]) }
      @c[:bar].x.should be_instance_of Foo
    end

    it "always returns the same instance" do
      @c.add(:foo) { Foo.new }
      @c[:foo].should equal @c[:foo]
    end
  end

  context "out-of-order dependencies" do
    it "is able to create the depending object" do
      @c.add(:bar) { |c| Bar.new(c[:foo]) }
      @c.add(:foo, Foo)
      @c[:bar].should be_instance_of Bar
    end
  end

  context "object not found" do
    it "raises an ObjectNotFoundError" do
      lambda { @c[:missing] }.
        should raise_error(Container::ObjectNotFoundError, /missing/)
    end
  end
  
  context "circular dependency" do
    it "raises a CircularDependencyError" do
      @c.add(:bar1) { |c| Bar.new(c[:bar2]) }
      @c.add(:bar2) { |c| Bar.new(c[:bar1]) }
      lambda { @c[:bar1] }.should raise_error SystemStackError
    end
  end

  describe "decoration" do
    it "decorates an existing class" do
      @c.add(:dec, ReturnsFive)
      @c.decorate(:dec, AddsTen)
      @c[:dec].x.should ==15
    end

    it "decorates with initializers" do
      @c.add(:dec) { ReturnsFive.new }
      @c.decorate(:dec) { AddsTen.new }
      @c[:dec].x.should ==15
    end

    it "passes the container to the initializer" do
      @c.add(:num) { 100 }
      @c.add(:dec) { ReturnsFive.new }
      @c.decorate(:dec) { |c| AddsX.new(c[:num]) }
      @c[:dec].x.should ==105
    end
    
    it "adds decorators in the order specified" do
      @c.add(:dec) { ReturnsFive.new }
      @c.decorate(:dec) { AddsTen.new }
      @c.decorate(:dec) { DividesByFive.new }
      @c[:dec].x.should ==3
    end
    
    it "allows decoration *of* objects with out-of-order dependencies" do
      @c.add(:dec) { |c| ReturnsX.new(c[:num]) }
      @c.decorate(:dec) { DividesByFive.new }
      @c.add(:num) { 100 }
      @c[:dec].x.should ==20
    end

    it "allows decoration *by* objects with out-of-order dependencies" do
      @c.add(:dec) { ReturnsFive.new }
      @c.decorate(:dec) { |c| AddsX.new(c[:num]) }
      @c.add(:num) { 100 }
      @c[:dec].x.should ==105
    end
    
    it "raises ObjectNotFoundError if decorated object can't be found" do
      lambda { @c.decorate(:missing) }.should raise_error Container::ObjectNotFoundError
    end
  end
end

describe Decorator do
  it "provides access to the decorated object" do
    class Decorated
      include Decorator
      def extract() wrapped end
    end
    decorated = Decorated.new.decorating 'foo'
    decorated.extract.should =='foo'
  end
end

class Foo
end

class Bar
  attr_reader :x
  def initialize(x) @x=x end
end

class ReturnsFive
  def x() 5 end
end

class AddsTen
  include Decorator
  def x() wrapped.x+10 end
end

class AddsX
  include Decorator
  def initialize(x) @x=x end
  def x() wrapped.x+@x end
end

class ReturnsX
  def initialize(x) @x=x end
  def x() @x end
end

class DividesByFive
  include Decorator
  def x() wrapped.x/5 end
end
