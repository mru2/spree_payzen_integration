PayzenIntegration
=================

To add Payzen Payment to Spree:

* include this gem in your gemfile

* run the generator: `rake payzen_integration:install`

* edit the `payzen.yml` file included in your `config` folder

* in your spree app, go to the backend and include Payzen to your list of Payments

* I guess, you'd like to adapt the design to your taste. Just grab the logic in the files: `checkout/_confirm` and `checkout/edit`

Tests
=====

Specs are included in a dummy app in `/test`.

To run all the tests, you'd have to add the `payzen.yml` file in the dummy app.

An extra key would be needed here: 

    signature: value_of_the_signature_of_the_test_hash_depending_on_your_credentials
    
To get this:

* go to the Rails console

* copy the hash form `spec/lib/payzen_integration_param`

* launch: `PayzenIntegration::Params.compute_signature(hash)`