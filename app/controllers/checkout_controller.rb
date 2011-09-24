# Handles checkout logic.  This is somewhat contrary to standard REST convention since there is not actually a
# Checkout object.  There's enough distinct logic specific to checkout which has nothing to do with updating an
# order that this approach is waranted.
class CheckoutController < Spree::BaseController
  ssl_required

  # Already executed in checkout controller before_filter :load_order 
  protect_from_forgery :except => [:payzen]
  
  rescue_from Spree::GatewayError, :with => :rescue_from_spree_gateway_error

  respond_to :html

  # Updates the order and advances to the next state (when possible.)
  def update
    if !@order.payzen_payment_step? and @order.update_attributes(object_params)
      # prevent update from => 'confirm',  to => 'complete' when payment is made with Payzen.
      if @order.next
        state_callback(:after)
      else
        flash[:error] = I18n.t(:payment_processing_failed)
        #respond_with(@order, :location => checkout_state_path(@order.state))
        redirect_to checkout_state_path(@order.state)
        return
      end

      if @order.state == "complete" || @order.completed?
        flash[:notice] = I18n.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route  
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end
  
  # Payzen server to server callback
  # ----------------------------------------------------------------------------------------------------------------------    ---------------------------------------------
  # | ID | From Payzen                 |  Order initial  | Order final |  Payment initial | Payment final  |  Payzen     |    |  ID |  Order     |  Payment | Payzen back |
  # ----------------------------------------------------------------------------------------------------------------------    ---------------------------------------------
  # | A  | post without vads_order_id  |     *           |     *       |                  |                | 404         |    | A   | confirm    |     *    | checkout    |
  # |    | or order not found          |                 |             |                  |                |             |    ---------------------------------------------
  # ----------------------------------------------------------------------------------------------------------------------    | B   | complete   |     *    | show order  |
  # | B  | post with order_id but      |  confirm        | canceled    |  checkout        |   fail         | 404         |    ---------------------------------------------
  # |    | wrong signature             |                 |             |  error           |                |             |    | C   | canceled   |     *    | root        |
  # ----------------------------------------------------------------------------------------------------------------------    ---------------------------------------------
  # | C  | post with wrong amount/curr |  confirm        | canceled    |  checkout/error  |   fail         | 404         |    | D   | not found  |     *    | 404         |
  # ----------------------------------------------------------------------------------------------------------------------    ---------------------------------------------
  # | D  | post with good signature    |  confirm        | confirm     |  checkout        |   error        | 200         |   
  # |    | and status canceled         |                 |             |                  |                |             |   
  # ----------------------------------------------------------------------------------------------------------------------    
  # | E  | post completely valid       |  confirm        | complete    |  checkout        |   complete     | 200         |    
  # ----------------------------------------------------------------------------------------------------------------------    
  # | F  | post completely valid       |  confirm        | complete    |  error           |   complete     | 200         |    
  # ----------------------------------------------------------------------------------------------------------------------    
  # | G  |        *                    |  complete       | unchanged   |      *           |        *       | 404         |    
  # ----------------------------------------------------------------------------------------------------------------------    
  # | H  |        *                    |  canceled       | unchanged   |      *           |        *       | 404         |    
  # ----------------------------------------------------------------------------------------------------------------------    
  # | I  |        *                    | anything but    |     *       |      *           |        *       | 404         |    
  # |    |                             | conf/comp/cancel|             |                  |                |             |    
  # ----------------------------------------------------------------------------------------------------------------------    
  def payzen
    # Get the order, payment and payzen parameters
    @order = Order.where(:number => params["vads_order_id"]).first # search by number (unique). Don't know why find_by_number fails here    
    
    render :status => 500, :text => "reference to invalid order"  and return if @order.nil? || !@order.confirm? #case A, G, H & I
    
    @payment = @order.payments.last
    @payment.started_processing
    
    # Check if the payment is ok
    begin 
      PayzenIntegration::Params.check_returned_signature(params)
      raise PayzenIntegration::Params::InvalidAmount unless PayzenIntegration::Params.conformity_between?(@order, params)
    rescue PayzenIntegration::Signature => e                #case B
      @payment.log_entries.create(:details => e.message) 
      @payment.fail
      @order.next   #:from => 'confirm',  :to => 'complete' 
      @order.cancel #:from => 'complete', :to => 'canceled' 
      render :status => 500, :text => "invalid query"
    rescue PayzenIntegration::Params::InvalidAmount => e    #case C
      @payment.log_entries.create(:details => e.message) 
      @payment.error
      @order.next   #:from => 'confirm',  :to => 'complete' 
      @order.cancel #:from => 'complete', :to => 'canceled' 
      redirect_to checkout_state_path("confirm") and return
    rescue PayzenIntegration::OrderCanceled => e            #case D
      @payment.log_entries.create(:details => e.message) 
      @payment.error
      render :status => 200, :text => "ok, order canceled"
    rescue Exception => e  #case C
      @payment.log_entries.create(:details => e.message) 
      @payment.error
      redirect_to checkout_state_path("confirm") and return
    end
    #case E and F
    @payment.complete
    @order.next       #:from => 'confirm', :to => 'complete' 
    state_callback(:after)
    render :status => 200, :text => "payment ok"
  end
  
  # Payzen return to website
  # ---------------------------------------------
  # |  ID |  Order     |  Payment | Payzen back |
  # ---------------------------------------------
  # | A   | confirm    | checkout | checkout    |
  # ---------------------------------------------
  # | B   | confirm    | error    | checkout    |
  # ---------------------------------------------
  # | C   | complete   |     *    | show order  |
  # ---------------------------------------------
  # | D   | canceled   |     *    | root        |
  # ---------------------------------------------
  # | E   | not found  |     *    | 404         |
  # ---------------------------------------------
  def payzen_back
    @order = Order.where(:number => params["vads_order_id"]).first # search by number (unique). Don't know why find_by_number fails here    
    render_404            and return if @order.nil?                              # case E
    redirect_to root_path and return if @order.canceled?                         # case D
    
    if @order.complete?                                                          # case C
      flash[:notice] = I18n.t(:order_processed_successfully)
      #flash[:commerce_tracking] = "nothing special" 
      redirect_to completion_route and return 
    elsif @order.confirm?
      if @order.payment.error?                                                   # case B
        flash[:notice] = "Vous avez quitté Payzen sans payer, si vous voulez annuler la commande cliquez sur le bouton..."
      end
    end
    # case A, nothing special to do and should never happen
    render "edit"
  end
  
  def destroy_current_order
    @order = current_order
    current_order.destroy unless @order.complete?
    redirect_to root_path
  end
  
  private

  # Provides a route to redirect after order completion
  def completion_route
    order_path(@order)
  end

  def object_params
    # For payment step, filter order parameters to produce the expected nested attributes for a single payment and its source, discarding attributes for payment methods other than the one selected
    if @order.payment?
      if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]
        params[:order][:payments_attributes].first[:source_attributes] = source_params
      end
      if (params[:order][:payments_attributes])
        params[:order][:payments_attributes].first[:amount] = @order.total
      end
    end
    params[:order]
  end

  def load_order
    @order = current_order
    redirect_to cart_path and return unless @order and @order.checkout_allowed?
    redirect_to cart_path and return if @order.completed?
    @order.state = params[:state] if params[:state] 
    state_callback(:before)
  end

  def state_callback(before_or_after = :before)
    method_name = :"#{before_or_after}_#{@order.state}"
    send(method_name) if respond_to?(method_name, true)
  end

  def before_address
    @order.bill_address ||= Address.default
    @order.ship_address ||= Address.default
  end

  def before_delivery
    return if params[:order].present?
    @order.shipping_method ||= (@order.rate_hash.first && @order.rate_hash.first[:shipping_method])
  end

  def before_payment
    current_order.payments.destroy_all if request.put?
  end

  def after_complete
    session[:order_id] = nil
  end

  def rescue_from_spree_gateway_error
    flash[:error] = t('spree_gateway_error_flash_for_checkout')
    render :edit
  end

end