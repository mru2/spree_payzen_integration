require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'ruby-debug'

describe CheckoutController do
  include Devise::TestHelpers
  let(:user)  { Factory :user  }
  
  before(:each) do
    sign_in user
  end
  
  describe "update method" do
    let(:order)  { Factory :order, :user => user }
    
    before(:each) do
      order.stub(:checkout_allowed?).and_return(true)
      Order.should_receive(:find_by_id).and_return(order)
      session[:order_id] = order.id
      order.stub(:next).and_return(true)
      order.stub(:update_attributes).and_return(true)
    end

    describe "with Payzen Payment Method" do
      before(:each) do
        order.stub_chain(:payment_method, :class).and_return(PaymentMethod::Payzen)
      end
      
      it "an order with 'confirm' state should not go to the next step" do
        order.stub(:state).and_return("confirm")
        order.should_not_receive(:next)
        get :update, :state => order.state
      end

      it "an order with 'cart', 'address' or 'delivery' should go to the next step" do
        ["cart", "address", "delivery"].each do |step|
          order.stub_chain(:state).and_return(step)
          order.should_receive(:next)
          get :update, :state => order.state
        end
      end
    end
    
    describe "with Payzen Payment Method" do
      before(:each) do
        order.stub_chain(:payment_method, :class).and_return(PaymentMethod::Check)
      end
      
      it "all kinds of order must go to the next step" do
        ["cart", "address", "delivery", "confirm"].each do |step|
          order.stub(:state).and_return(step)
          order.should_receive(:next)
          get :update, :state => order.state
        end
      end
    end
  end
  
  describe "payzen action" do
    before(:each) do
      @order = Factory :order, :user => user
      @payment = double("payment")      
      @payment.stub(:started_processing)
      @payment.stub(:complete)      
      @payment.stub(:fail)
      @order.stub_chain(:payments, :last).and_return(@payment)
      Order.stub(:where).and_return [@order]
    end
    
    it "should fail to complete payment with partial attributes" do
      PayzenIntegration::Params.should_receive(:check_returned_params).and_raise
      @payment.should_receive(:fail)    
      get :payzen
    end
    
    it "should complete payment with valid attributes" do
      PayzenIntegration::Params.should_receive(:check_returned_params).and_return(:true)
      @payment.should_receive(:complete)    
      get :payzen
    end
  end
end