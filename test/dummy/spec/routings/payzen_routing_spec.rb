require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Payzen Routes" do
  it "confirm route" do
    { :post => "payment/payzen/confirm" }.
      should route_to(
        :controller => "checkout",
        :action => "payzen"
      )
  end
  
  it "confirm route, no get" do
    { :get => "payment/payzen/confirm" }.
      should_not route_to(
        :controller => "checkout",
        :action => "payzen"
      )
  end
  
  it "back from payzen route" do
    { :post => "payment/payzen/back" }.
      should route_to(
        :controller => "checkout",
        :action => "payzen_back"
      )
  end

  it "back from payzen route, no get" do
    { :get => "payment/payzen/back" }.
      should_not route_to(
        :controller => "checkout",
        :action => "payzen_back"
      )
  end
    
  it "back from payzen route" do
    { :get => "payment/payzen/cancel" }.
      should route_to(
        :controller => "checkout",
        :action => "destroy_current_order"
      )
  end
  
end