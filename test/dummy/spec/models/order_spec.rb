require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Order do
  let(:order)  { Factory :order, :state => "confirm" }
  let(:order2) { Factory :order, :state => "confirm" }
  let(:order3) { Factory :order, :state => "cart" }
  
  before(:each) do
    order.stub_chain(:payment_method, :class).and_return(PaymentMethod::Payzen)
    order2.stub_chain(:payment_method, :class).and_return(PaymentMethod::Check)
    order3.stub_chain(:payment_method, :class).and_return(PaymentMethod::Payzen)
  end
  
  specify { order.check_payzen.should  be_false }
  specify { order2.check_payzen.should be_true }
  specify { order3.check_payzen.should be_true }
  
end