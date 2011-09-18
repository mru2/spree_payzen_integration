require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'ruby-debug'

describe CheckoutController do
  include Devise::TestHelpers
  let(:user)  { Factory :user  }
  
  before(:each) do
    sign_in user
  end
  
  describe "update method" do
    let(:order_confirm)  { Factory :order, :user => user, :state => "confirm" }
    let(:order_cart)     { Factory :order, :user => user, :state => "address" }
    
    before(:each) do
      order_confirm.stub(:checkout_allowed?).and_return(true)
      Order.should_receive(:find_by_id).and_return(order_confirm)
    end
    
    it "an order with 'confirm' state and 'Payzen' payment method should not be changed through update" do
       session[:order_id] = order_confirm.id
       order_confirm.stub_chain(:payment_method, :class).and_return(PaymentMethod::Payzen)
       get :update, :state => order_confirm.state
       debugger
       controller.params[:state].should eq "confirm" #means we remained on the samed page which is what was expected.
    end
    
    # transition :from => 'cart',     :to => 'address'
    # transition :from => 'address',  :to => 'delivery'
    # transition :from => 'delivery', :to => 'payment'
    # transition :from => 'confirm',  :to => 'complete'
    # 
    # # note: some payment methods will not support a confirm step
    # transition :from => 'payment',  :to => 'confirm',
    #                                 :if => Proc.new { G
    
    it "should put order in all states but 'confirm' to the next step" do
      pending
      session[:order_id] = order_cart.id
      order_cart.stub_chain(:payzen_validation, :class).and_return(PaymentMethod::Payzen)
      order_cart.stub(:next).and_return(true)
      #order_cart.should_receive :payzen_validation
      #order_cart.should_receive(:checkout_allowed)
      controller.should_receive :load_order
      get :update, :state => order_cart.state
      #order_cart.reload.state.should eq "confirm"
    end
  end
  
  describe "payzen action" do
    before(:each) do
      @order = Factory :order, :user => user
      @payment  = double("payment")      
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