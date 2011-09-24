Spree::BaseController.class_eval do

  before_filter :redirect_if_checkout_and_payzen
  
  #once user is at 'confirm' step and pays with Payzen, he can't go back. he can only destory his order
  def redirect_if_checkout_and_payzen
    @order = current_order
    redirect_to checkout_state_path("confirm") and return if @order and @order.payzen_payment_step? and not belongs_to_authorized_page?
  end
  
  def belongs_to_authorized_page?
    params[:controller] == "checkout" and (params[:action] == "destroy_current_order" or params[:state] == "confirm")
  end
  
end
