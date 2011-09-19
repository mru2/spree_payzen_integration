Order.class_eval do
  # Order description sent to payzen
  def info
    # Newlines are trouble with payzen (only accepts alphanumerical characters...)
    info = ""
    info << "Order:#{id} -- "
    info << "Customer:#{user.email}/#{user.id} -- "
    line_items.each do |item|
      info << "#{item.product.name}(#{item.price})x#{item.quantity} -- "
    end
    return info
  end
  
  def payzen_payment_step?
    if self.state == "confirm" and self.payment_method.class == PaymentMethod::Payzen
      true
    else
      false 
    end
  end
  
  
end