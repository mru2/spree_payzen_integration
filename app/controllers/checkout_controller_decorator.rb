CheckoutController.class_eval do

  before_filter :check_authorization, :except => :payzen
  before_filter :check_registration, :except => [:payzen, :registration, :update_registration]
  before_filter :load_order, :except => [:payzen, :payzen_back]
  
  helper :users
  
  def redirect_if_checkout_and_payzen
    @order = current_order
    redirect_to checkout_state_path("confirm") and return if @order and @order.payzen_payment_step? and not belongs_to_authorized_page?
  end
  
  def belongs_to_authorized_page?
    params[:controller] == "checkout" and (params[:action] == "destroy_current_order" or params[:state] == "confirm")
  end

  def registration
    @user = User.new
  end

  def update_registration
    # hack - temporarily change the state to something other than cart so we can validate the order email address
    current_order.state = "address"
    if current_order.update_attributes(params[:order])
      redirect_to checkout_path
    else
      @user = User.new
      render 'registration'
    end
  end

  private
  def check_authorization
    authorize!(:edit, current_order, session[:access_token])
  end

  # Introduces a registration step whenever the +registration_step+ preference is true.
  def check_registration
    return unless Spree::Auth::Config[:registration_step]
    return if current_user or (current_order && current_order.email)
    store_location
    redirect_to checkout_registration_path
  end

  # Overrides the equivalent method defined in spree_core.  This variation of the method will ensure that users
  # are redirected to the tokenized order url unless authenticated as a registered user.
  def completion_route
    return order_path(@order) if current_user
    token_order_path(@order, @order.token)
  end

end
