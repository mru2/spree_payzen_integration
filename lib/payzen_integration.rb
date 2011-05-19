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

      # Disallow ssl in production
      Spree::Config.set(:allow_ssl_in_production => false) if defined?(Spree::Config)
    end

    config.to_prepare &method(:activate).to_proc

    # Initialize the payzen config YAML
    initializer 'payzen_integration.load_config' do |app|
      PAYZEN_CONFIG = YAML.load_file("#{Rails.root}/config/payzen.yml")      
    end

  end
end

require 'payzen_integration/config'
require 'payzen_integration/params'