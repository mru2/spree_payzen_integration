PayzenIntegration
=================

To add Payzen Payment to Spree:

* include this gem in your gemfile

* run the generator: `rake payzen_integration:install`

* edit the `payzen.yml` file included in your `config` folder

* in your spree app, go to the backend and include Payzen to your list of Payments

* I guess, you'd like to adapt the design to your taste. Just grab the logic in the files: `checkout/_confirm` and `checkout/edit`

