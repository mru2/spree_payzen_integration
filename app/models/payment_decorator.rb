Payment.class_eval do

  # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
  state_machine :initial => 'checkout' do
    # With card payments, happens before purchase or authorization happens
    event :started_processing do
      transition :from => ['checkout', 'pending', 'completed', 'error'], :to => 'processing'
    end
    # When processing during checkout fails
    event :fail do
      transition :from => 'processing', :to => 'failed'
    end
    
    #this represents error from payzen
    event :error do
      transition :from => ['checkout', 'pending', 'completed', 'processing'], :to => 'error'
    end
    
    # With card payments this represents authorizing the payment
    event :pend do
      transition :from => 'processing', :to => 'pending'
    end
    # With card payments this represents completing a purchase or capture transaction
    event :complete do
      transition :from => ['processing', 'pending'], :to => 'completed'
    end
    event :void do
      transition :from => ['pending', 'completed'], :to => 'void'
    end
  end

end