Factory.define :payzen_method, :class => PaymentMethod::Payzen do |f|
  f.name 'PaymentMethod::Payzen'
  f.environment 'rspec'
end

Factory.define :bogus_method, :class => PaymentMethod::Check do |f|
  f.name 'PaymentMethod::Check'
  f.environment 'rspec'
end

#
# Factory.define :authorize_net_payment_method, :class => Gateway::AuthorizeNet do |f|
#   f.name 'Credit Card'
#   f.environment 'cucumber'
#   #f.display_on :front_end
# end
