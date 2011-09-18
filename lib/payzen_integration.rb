require 'spree_core'
require 'payzen_integration_hooks'

module PayzenIntegration
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      
      # Register the payment method
      PaymentMethod::Payzen.register

    end

    config.to_prepare &method(:activate).to_proc
  end
end

require 'payzen_integration/config'
require 'payzen_integration/params'