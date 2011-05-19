# Callbacks to test!! #

CheckoutController.class_eval do

  # Already executed in checkout controller before_filter :load_order 
  protect_from_forgery :except => [:payzen]

  # The current order doesn't exist anymore, we don't want to load it
  before_filter :load_order, :except => :payzen_back
  
  # The admin privileges are asked for payzen_back
  # This fixes the issue (the user still need to be logged in)
  before_filter :check_authorization, :except => :payzen_back
  
  # Payzen asynchronous callback
  def payzen
    # Get the order, payment and payzen parameters
    if Rails.env == 'production'
      @order = Order.find_by_number(params["vads_order_id"]) # pas l'ID, le number (mais unique aussi)
    else
      @order = current_order
    end
    
    @payment = @order.payments.last
    @payment.started_processing
    
    # Check if the payment is ok
    begin 
      PayzenIntegration::Params.check_returned_params(params) if Rails.env == 'production'
    rescue Exception => e
      # log the exception ? Save it as a payment parameter ?
      @payment.fail
      render :text => "Payzen error : #{e.message} for order #{@order.id}" and return
    end
  
    @payment.complete

    @order.next #:from => 'payment', :to => 'confirm' 
    state_callback(:after)

    state_callback(:before)
    @order.next #:from => 'confirm', :to => 'complete' 
    state_callback(:after)
    render :text => "done"
  end
    
  # Payzen return to website
  def payzen_back
    # Get the last order
    @order = current_user.orders.complete.last    
    redirect_to cart_path and return unless @order
     
    # Show the summary
    flash[:notice] = I18n.t(:order_processed_successfully)
    flash[:commerce_tracking] = "nothing special"    
    render "orders/show"
  end
  
  
end