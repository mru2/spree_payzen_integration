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
  end
  
  describe "instance methods" do
    
    let(:params) { PayzenIntegration::Params.new }
    
    describe "create_string_from_config_hash" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public :create_string_from_config_hash }
        PayzenIntegration::Config.stub(:get).and_return 12345
      end

      it "should sort hash" do
        hash = { :b => "b", :a => 1, :c => "c"}
        params.create_string_from_config_hash(hash).should eq "1+b+c+12345"
      end
    
      after(:each) do
        PayzenIntegration::Params.class_eval { private :create_string_from_config_hash }
      end
    end
    
    describe "compute_signature" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public :compute_signature }
        params.stub(:create_string_from_config_hash).and_return "test"
      end

      it "should " do
        Digest::SHA1.stub :hexdigest
        Digest::SHA1.should_receive(:hexdigest).with "test"
        params.compute_signature({ :a => "a" })
      end
      
      after(:each) do
        PayzenIntegration::Params.class_eval { private :compute_signature }
      end
    end
    
    describe "payzen_param_hash" do
      before(:each) do
        PayzenIntegration::Params.class_eval { public :payzen_param_hash }
        @saved_const = PayzenIntegration::Params::PARAMS
        PayzenIntegration::Params.const_set(:PARAMS, [:foo, :bar])
        params.stub(:foo).and_return "foo_value"
        params.stub(:bar).and_return "bar_value"
      end
      
      it "should render the proper hash" do
        params.payzen_param_hash.should eq({:foo => "foo_value", :bar => "bar_value"})
      end

      after(:each) do
        PayzenIntegration::Params.class_eval { private :payzen_param_hash }
        PayzenIntegration::Params.const_set(:PARAMS, @saved_const)
      end
    end
    
  end
end