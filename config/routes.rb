Rails.application.routes.draw do
  # Add your extension routes here

  match 'payment/payzen/confirm' => 'checkout#payzen', :as => :payzen
  match 'payment/payzen/back' => 'checkout#payzen_back', :as => :payzen_back
end
