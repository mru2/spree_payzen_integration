require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require 'ruby-debug'

describe CheckoutController do
  
  describe "tests using simplified factories" do
    let(:user)  { Factory :user  }
    include Devise::TestHelpers
  
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
        
        it "once reached 'confirm' step with 'Payzen' payment method, user can't go back to another checkout step" do
          session[:order_id] = order
          order.stub(:state).and_return("confirm")
          
          get :edit, :state => "payment"
  
          response.status.should eq 302
          response.body.should include "/checkout/confirm"
        end
      end
    
      describe "with Check Payment Method" do
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
    
    describe "payzen_back" do
      it "should redirect to checkout when current_order isn't complete" do
        
      end
    end
  end
  
  describe "payzen action" do
    
    describe "stubbed logic" do
      before(:each) do
        #controller.class.skip_before_filter :check_authorization
        #@order = Factory :order_without_user
        #@payment = double("payment")      
        #@payment.stub(:started_processing)
        #@payment.stub(:complete)      
        #@payment.stub(:fail)
        #@order.stub_chain(:payments, :last).and_return(@payment)
      end
        
      # it "posting to 'payzen' action should not require to be logged in" do
      #   post :payzen
      # end
      #     
      # it "post with no attributes should render 404" do
      #   post :payzen
      #   @payment.should_not_receive(:started_processing)
      #   response.status.should eq 404
      # end
      #  
      # it "should fail to complete payment with partial attributes" do
      #   Order.stub(:where).and_return [@order]
      #   PayzenIntegration::Params.should_receive(:check_returned_signature).and_raise
      #  
      #   @payment.should_receive(:fail)    
      #   get :payzen
      # end
      #  
      # it "should complete payment with valid attributes" do
      #   Order.stub(:where).and_return [@order]
      #   PayzenIntegration::Params.should_receive(:check_returned_signature).and_return(:true)
      #  
      #   @payment.should_receive(:complete)    
      #   get :payzen
      # end  
    end
  
    describe "tests using real and full fixtures" do
    
      fixtures_list = Dir[Rails.root.join("spec/support/fixtures/*.yml")].map { |f| f.scan(/.*\/(.*)\.yml/).first.first.to_sym } 
      fixtures *fixtures_list
    
      let(:order) { Order.where(:number => "R425653488").first }
      before(:each) do
        @basic_payzen_post = { :vads_action_mode            => "INTERACTIVE", 
                               :vads_payment_config         => "SINGLE", 
                               :vads_ctx_mode               => "TEST", 
                               :vads_threeds_status         => "", 
                               :vads_threeds_eci            => "", 
                               :vads_page_action            => "PAYMENT", 
                               :vads_threeds_cavv           => "", 
                               :vads_effective_amount       => "4098", 
                               :vads_payment_certificate    => "bade02a27471188a461453ab5470cc61ff88fee3", 
                               :vads_card_number            => "[FILTERED]", 
                               :vads_subscription           => "", 
                               :vads_validation_mode        => "0", 
                               :vads_cust_email             => "spree@example.com", 
                               :vads_trans_id               => "677725", 
                               :vads_site_id                => "99563855", 
                               :vads_card_country           => "FR", 
                               :signature                   => nil,
                               :vads_currency               => "978", 
                               :vads_result                 => "00", 
                               :vads_threeds_cavvAlgorithm  => "", 
                               :vads_pays_ip                => "FR", 
                               :vads_threeds_error_code     => "", 
                               :vads_identifier             => "", 
                               :vads_contract_used          => "000002", 
                               :vads_auth_number            => "012345678", 
                               :vads_url_check_src          => "PAY", 
                               :vads_threeds_exit_status    => "", 
                               :vads_expiry_year            => "2012", 
                               :vads_auth_result            => "00", 
                               :vads_expiry_month           => "6", 
                               :vads_warranty_result        => "NO", 
                               :path                        => "yo", 
                               :vads_order_info             => "Order: foo -- Customer:spree@example.com/ --", 
                               :vads_hash                   => "Oebgd7nhtjghdN0ubNqn3r1fQ8Rowv8xj9Y1zSyuw1Q", 
                               :vads_threeds_sign_valid     => "", 
                               :vads_threeds_xid            => "", 
                               :vads_threeds_enrolled       => "", 
                               :vads_amount                 => "4098", 
                               :vads_language               => "fr", 
                               :vads_card_brand             => "CB", 
                               :vads_capture_delay          => "0", 
                               :vads_version                => "V2", 
                               :vads_trans_date             => "20110920224611", 
                               :vads_order_id               => "R425653488", 
                               :vads_extra_result           => "", 
                               :vads_auth_mode              => "FULL"
                               }
         @basic_payzen_post[:signature] = PayzenIntegration::Params.compute_signature(@basic_payzen_post)
      end
    
      it "valid post to 'payzen' should complete order & payment" do
        post :payzen, @basic_payzen_post
      
        order.reload.state.should eq "complete"
        order.payment.state.should eq "completed"
        response.body.should eq "done"
      end
      
      it "invalid post to 'payzen' should close the order & validate payment" do
        @basic_payzen_post.merge!({:signature => "invalid"})
        post :payzen, @basic_payzen_post
      
        #order.reload.state.should eq "canceled"
        order.payment.state.should eq "failed"
        response.status.should eq 404
      end
    end
  end
end