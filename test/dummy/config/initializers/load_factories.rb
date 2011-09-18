if Rails.env.development?
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
end