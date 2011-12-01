Spree::BaseController.class_eval do

  before_filter :redirect_if_checkout_and_payzen
  
  #once user is at 'confirm' step and pays with Payzen, he can't go back. he can only destory his order
  def redirect_if_checkout_and_payzen
    @order = current_order
    if (@order && @order.payzen_payment_step? && !belongs_to_payzen_authorized_page?(params))
      flash.keep
      redirect_to checkout_state_path("confirm") and return 
    end
  end
  
  def belongs_to_payzen_authorized_page? paramz
    paramz[:controller] == "checkout" && ( ["destroy_current_order", "payzen_back"].include?(paramz[:action]) || (["edit", "update"].include?(paramz[:action]) && paramz[:state] == "confirm"))
  end
  
end

  
  # Started POST "/payment/payzen/back" for 86.211.31.250 at Mon Nov 21 21:48:20 +0100 2011
  #   Processing by CheckoutController#payzen_back as HTML
  #   Parameters: {"vads_action_mode"=>"INTERACTIVE", "vads_payment_config"=>"SINGLE", "vads_ctx_mode"=>"TEST", 
  # "vads_threeds_status"=>"Y", "vads_threeds_eci"=>"05", "vads_page_action"=>"PAYMENT", "vads_threeds_cavv"=>"Q2F2dkNhdnZDYXZ2Q2F2dkNhdnY=",
  # "vads_effective_amount"=>"1320", "vads_payment_certificate"=>"5d5d6e8364f761f6c6b9fd3cd7e732f45890aaac",
  # "vads_card_number"=>"[FILTERED]", "vads_subscription"=>"", "vads_validation_mode"=>"0", "vads_cust_email"=>"broth@peachyweb.com",
  # "vads_trans_id"=>"214518", "vads_site_id"=>"99563855", "vads_card_country"=>"FR", "signature"=>"0aea8a469bdcfc38d4618f54aa73ce1099f72744",
  # "vads_currency"=>"978", "vads_result"=>"00", "vads_threeds_cavvAlgorithm"=>"2", "vads_pays_ip"=>"FR", "vads_threeds_error_code"=>"", "vads_identifier"=>"",
  # "vads_contract_used"=>"000002", "vads_auth_number"=>"[FILTERED]", "vads_threeds_exit_status"=>"10", "vads_expiry_year"=>"2012", "vads_auth_result"=>"00",
  # "vads_expiry_month"=>"6", "vads_warranty_result"=>"YES", "vads_order_info"=>"Order:12 -- Customer:broth@peachyweb.com/1 -- test(12.0)x1 -- ", "vads_threeds_sign_valid"=>"1",
  # "vads_threeds_xid"=>"X2IxZTkzM2U2LTBhNmUtNGU2Ny0=", "vads_threeds_enrolled"=>"Y", "vads_amount"=>"1320", "vads_language"=>"fr", "vads_card_brand"=>"CB",
  # "vads_capture_delay"=>"0", "vads_version"=>"V2", "vads_trans_date"=>"20111121214518", "vads_order_id"=>"R302001774", "vads_extra_result"=>"", "vads_auth_mode"=>"FULL"}
  # Redirected to https://emonetique.com/login
  # Completed 302 Found in 93ms