require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PayzenIntegration::Config do
  it "should find yml file and return it's strings" do
    PayzenIntegration::Config.get(:ctx_mode).should be_a String
  end
end


describe "Payzen load" do
  it "should have been regitered as Payment method" do
    Gateway.providers.map(&:name).should include "PaymentMethod::Payzen"
  end
  
  it "should be a sublass of PaymentMethod" do
    PaymentMethod::Payzen.ancestors.should include(PaymentMethod)
  end

  describe "subject" do
    let(:payzen) { PaymentMethod::Payzen.new }
    
    it "instance method 'payment_profiles_supported?' should exist" do
      payzen.respond_to?(:payment_profiles_supported?).should be_true
    end

    it "instance method 'payment_profiles_supported?' should return true" do
      payzen.payment_profiles_supported?.should be_true
    end
  end

end