require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutController do
  include Devise::TestHelpers
  let(:user)           { Factory :user  }
  before(:each) do
    sign_in user
  end
  
  describe "update method" do
    let(:order_confirm)  { Factory :order, :user => user, :state => "confirm" }
    let(:order_cart)     { Factory :order, :user => user, :state => "address" }
    
    it "an order with 'confirm' state and 'Payzen' payment method should not be changed through update" do
       pending
       session[:order_id] = order_confirm.id
       order_confirm.stub_chain(:payzen_validation, :class).and_return(PaymentMethod::Payzen)
       get :update, :state => order_confirm.state
      #order_confirm.should_receive :payzen_validation
      #order_confirm.reload.state.should eq "confirm"
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
      @valid_payzen_attributes = {
      :signature            => "42d7a67a72e36f4b5b69c3ecbae9283542d5a5c5",
      :vads_action_mode     => "INTERACTIVE",
      :vads_amount          => 2299,
      :vads_currency        => "978",
      :vads_cust_email      => "spree@example.com",
      :vads_ctx_mode        => "TEST",
      :vads_order_id        => "R281721355",
      :vads_order_info      => "Order:1069267033 -- Customer:spree@example.com/1 -- Ruby on Rails Ringer T-Shirt(17.99)x1 -- ",
      :vads_page_action     => "PAYMENT",
      :vads_payment_config  => "SINGLE",
      :vads_site_id         => "99563855",
      :vads_trans_date      => "20110918222213",
      :vads_trans_id        => "067033",
      :vads_validation_mode => "0",
      :vads_version         => "V2"
      }
      @order = Factory :order, :number => @valid_payzen_attributes[:vads_order_id], :user => user
    end
    
    it "should find the created order" do
      @order.stub_chain(:payments,:last).and_return(Factory :payment)
      get :payzen, @valid_payzen_attributes
    end
    
    
    
  end
  
end