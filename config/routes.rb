Rails.application.routes.draw do
  # Add your extension routes here
  scope 'payment/payzen/' do
    match 'confirm' => 'checkout#payzen',                :as => :payzen               , :via => :post
    match 'back'    => 'checkout#payzen_back',           :as => :payzen_back          , :via => :post
    match 'cancel'  => 'checkout#destroy_current_order', :as => :destroy_current_order, :via => :get
  end
end
