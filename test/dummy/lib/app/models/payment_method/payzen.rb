class PaymentMethod::Payzen < PaymentMethod
  def payment_profiles_supported?
    true
  end
end