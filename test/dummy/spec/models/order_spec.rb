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
  
  specify { order.payzen_payment_step?.should  be_true }
  specify { order2.payzen_payment_step?.should be_false }
  specify { order3.payzen_payment_step?.should be_false }
  
end