require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Payzen Routes" do
  it "confirm route" do
    { :get => "payment/payzen/confirm" }.
      should route_to(
        :controller => "checkout",
        :action => "payzen"
      )
  end
  
  it "back from payzen route" do
    { :get => "payment/payzen/back" }.
      should route_to(
        :controller => "checkout",
        :action => "payzen_back"
      )
  end
end