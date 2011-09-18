require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
 
describe PayzenIntegration::Params do
  
  describe "class methods" do
    describe "fill_with_zero" do
      it "should render 000001 from 1" do
        PayzenIntegration::Params.fill_with_zero(1,6).should eq "000001" 
      end

      it "should render 1234567890 from 1234567890" do
        PayzenIntegration::Params.fill_with_zero("1234567890",6).should eq "1234567890" 
      end
    end

    describe "self.trans_id(order)" do
      let(:order) { double("order") }
      it "should " do
        order.stub(:id).and_return 1
        PayzenIntegration::Params.should_receive(:fill_with_zero).with(1,6)
        PayzenIntegration::Params.trans_id(order)
      end

      it "should " do
        order.stub(:id).and_return 900001
        PayzenIntegration::Params.should_receive(:fill_with_zero).with(1,6)
        PayzenIntegration::Params.trans_id(order)
      end
    end

    describe "self.trans_date" do
      it "should format time properly" do
        Time.stub(:now).and_return Time.new(2011,11,30,23, 55,00)
        PayzenIntegration::Params.trans_date.should eq "20111130235500"
      end
    end
    
    describe "self.for_order" do
       let(:order)        { Factory :order, :number => "R763468221", :total => 120.00 }
       let(:payzen_param) { PayzenIntegration::Params.for_order(order) }
       
       before(:each) do
         PayzenIntegration::Config.stub(:get) do |arg|
          if arg == :ctx_mode; "TEST"; elsif arg == :site_id; "site"; end 
         end
         PayzenIntegration::Params.stub(:trans_date).and_return("trans_date")
         PayzenIntegration::Params.stub(:trans_id).and_return("trans_id")
         order.stub(:info).and_return("order_info")
       end
       
       it "should return an object" do
         payzen_param.should be_a PayzenIntegration::Params
       end
       
       specify { payzen_param.vads_action_mode.should eq "INTERACTIVE" }
       specify { payzen_param.vads_amount.should eq 12000 }
       specify { payzen_param.vads_ctx_mode.should eq "TEST" }
       specify { payzen_param.vads_currency.should eq "978" }
       specify { payzen_param.vads_cust_email.should eq order.user.email }
       specify { payzen_param.vads_order_id.should eq "R763468221" }
       specify { payzen_param.vads_page_action.should eq "PAYMENT" }
       specify { payzen_param.vads_payment_config.should eq "SINGLE" }
       specify { payzen_param.vads_validation_mode.should eq "0" }
       specify { payzen_param.vads_version.should eq "V2" }
       specify { payzen_param.vads_site_id.should eq "site" }
       specify { payzen_param.vads_trans_date.should eq "trans_date" }
       specify { payzen_param.vads_trans_id.should eq "trans_id" }
       specify { payzen_param.vads_order_info.should eq "order_info" }
    end
    
    describe "self.check_returned_params" do
      
      before(:each) do
        @valid_payzen_attributes = {
         :signature                => PayzenIntegration::Config.get(:signature),
         :vads_action_mode         => "INTERACTIVE",
         :vads_amount              => 2299,
         :vads_currency            => "978",
         :vads_cust_email          => "spree@example.com",
         :vads_ctx_mode            => "TEST",
         :vads_order_id            => "R281721355",
         :vads_order_info          => "Order:1069267033 -- Customer:spree@example.com/1 -- Ruby on Rails Ringer T-Shirt(17.99)x1 -- ",
         :vads_page_action         => "PAYMENT",
         :vads_payment_config      => "SINGLE",
         :vads_site_id             => "99563855",
         :vads_trans_date          => "20110918222213",
         :vads_trans_id            => "067033",
         :vads_validation_mode     => "0",
         :vads_version             => "V2",
         :vads_result              => "00", 
         :vads_payment_certificate => "certificat", 
         :vads_auth_mode           => "FULL"
         }
      end

      it "should succeed with valid attibutes" do
        PayzenIntegration::Params.check_returned_params(@valid_payzen_attributes).should be_true
      end
      
      it "should raise if vads_result is different from 00" do
        lambda { PayzenIntegration::Params.check_returned_params(@valid_payzen_attributes.merge!({:vads_result => "wrong"})) }.should raise_error PayzenIntegration::ReturnCode
      end
      
      it "should raise if vads_payment_certificate is empty" do
        lambda { PayzenIntegration::Params.check_returned_params(@valid_payzen_attributes.merge!({:vads_payment_certificate => ""})) }.should raise_error PayzenIntegration::PaymentCertificate
      end
      
      it "should raise if auth_mode is wrong" do
        lambda { PayzenIntegration::Params.check_returned_params(@valid_payzen_attributes.merge!({:vads_auth_mode => "bad"})) }.should raise_error PayzenIntegration::AuthMode
      end
      
      it "should raise if vads_payment_certificate is empty" do
        lambda { PayzenIntegration::Params.check_returned_params(@valid_payzen_attributes.merge!({:signature => "bad"})) }.should raise_error PayzenIntegration::Signature
      end
      
    end
    
    
    describe "create_string_from_config_hash" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public_class_method :create_string_from_config_hash }
        PayzenIntegration::Config.stub(:get).and_return 12345
      end

      it "should sort hash" do
        hash = { :b => "b", :a => 1, :c => "c"}
        PayzenIntegration::Params.create_string_from_config_hash(hash).should eq "1+b+c+12345"
      end
    
      after(:each) do
        PayzenIntegration::Params.class_eval { private_class_method :create_string_from_config_hash }
      end
    end
    
    describe "compute_signature" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public_class_method :compute_signature }
        PayzenIntegration::Params.stub(:create_string_from_config_hash).and_return "test"
      end

      it "should " do
        Digest::SHA1.stub :hexdigest
        Digest::SHA1.should_receive(:hexdigest).with "test"
        PayzenIntegration::Params.compute_signature({ :a => "a" })
      end
      
      after(:each) do
        PayzenIntegration::Params.class_eval { private_class_method :compute_signature }
      end
    end
    
  end
  
  describe "instance methods" do
    let(:param) { PayzenIntegration::Params.new }
    describe "payzen_param_hash" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public :payzen_param_hash }
        @saved_const = PayzenIntegration::Params::PARAMS
        PayzenIntegration::Params.const_set(:PARAMS, [:foo, :bar])
        param.stub(:foo).and_return "foo_value"
        param.stub(:bar).and_return "bar_value"
      end
      
      it "should render the proper hash" do
        param.payzen_param_hash.should eq({:foo => "foo_value", :bar => "bar_value"})
      end

      after(:each) do
        PayzenIntegration::Params.class_eval { private :payzen_param_hash }
        PayzenIntegration::Params.const_set(:PARAMS, @saved_const)
      end
    end
  end
end