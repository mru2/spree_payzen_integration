Spree::BaseController.class_eval do

  before_filter :redirect_if_checkout_and_payzen
  
  #once user is at 'confirm' step and pays with Payzen, he can't go back. he can only destory his order
  def redirect_if_checkout_and_payzen
    @order = current_order
    redirect_to checkout_state_path("confirm") and return if (@order && @order.payzen_payment_step? && !belongs_to_payzen_authorized_page?(params))
  end
  
  def belongs_to_payzen_authorized_page? paramz
    paramz[:controller] == "checkout" && ( ["destroy_current_order", "payzen_back"].include?(paramz[:action]) || (["edit", "update"].include?(paramz[:action]) && paramz[:state] == "confirm"))
  end
  
end
