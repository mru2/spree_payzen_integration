require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PayzenIntegration::Config do
  it "should find yml file and return it's strings" do
    PayzenIntegration::Config.get(:ctx_mode).should be_a String
  end
end