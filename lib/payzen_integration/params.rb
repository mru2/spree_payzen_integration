module PayzenIntegration

  class ReturnCode < StandardError; end
  class PaymentCertificate < StandardError; end
  class AuthMode < StandardError; end
  class Signature < StandardError; end
  class InvalidAmount < StandardError; end
  class OrderCanceled < StandardError; end

  # Represents the params sent to and returned from payzen
  class Params
    
    # The param names
    PARAMS = [ :vads_action_mode,
               :vads_amount,
               # :vads_contracts,
               :vads_ctx_mode,
               :vads_currency,
               :vads_cust_email,
               :vads_order_id,
               :vads_order_info,
               :vads_page_action,
               :vads_payment_config,
               :vads_site_id,
               :vads_trans_date,
               :vads_trans_id,
               :vads_validation_mode,
               :vads_version,
               :vads_return_mode ]
               
    # Create the accessors and assessors
    PARAMS.each{|p| attr_accessor p}

    # Returns the signature of a set of params
    def signature
      self.class.compute_signature payzen_param_hash
    end

    # Create the params from an order
    def self.for_order(order)
      p = self.new
      p.vads_action_mode      = "INTERACTIVE"                               # acquisition des données par carte déléguée à plateforme payzen
      p.vads_amount           = (order.total * 100).to_i                    # montant en centimes d'euros, Nombre entier!
      # p.vads_contracts      = order.number                                # numero de contrat en interne (relatif au num de transaction?)
      p.vads_ctx_mode         = (PayzenIntegration::Config.get :ctx_mode)   # TEST ou PRODUCTION
      p.vads_currency         = "978"                                       # correspond à l'euro
      p.vads_cust_email       = order.email                                 # email de l'acheteur
      p.vads_order_id         = order.number                                # numero de commande
      p.vads_order_info       = order.info                                  # infos relatives à la commande
      p.vads_page_action      = 'PAYMENT'                                   # unique valeur
      p.vads_payment_config   = 'SINGLE'                                    # pour paiement en une fois, on est pas Emmaus
      p.vads_site_id          = (PayzenIntegration::Config.get :site_id)    # notre identifiant
      p.vads_trans_date       = trans_date                                  # Correspond à la date locale du site marchand au format AAAAMMJJHHMMSS.
      p.vads_trans_id         = trans_id                                    # Ce paramètre est obligatoire. Il est constitué de 6 caractères numériques et doit être unique pour chaque transaction pour une boutique donnée sur la journée. En effet l'identifiant unique de transaction au niveau de la plateforme de paiement est constitué du vads_site_id, de vads_trans_date restreint à la valeur de la journée (partie correspondant à AAAAMMJJ) et de vads_trans_id. Il est à la charge du site marchand de garantir cette unicité sur la journée. Il doit être impérativement compris entre 000000 et 899999. La tranche 900000 et 999999 est interdite. Remarque : une valeur de longueur inférieure à 6 provoque une erreur lors de l’appel à l’URL de paiement. Merci de respecter cette longueur de 6 caractères.
      p.vads_validation_mode  = "0"                                         # validation automatique, 1 pour manuelle sur back office payzen
      p.vads_version          = 'V2'                                        # doit rester inchangé (tant qu'on utilise la V2!)
      p.vads_return_mode      = 'POST'                                     
      p
    end
    
    # Check the validity of the returned params from payzen
    def self.check_returned_signature(params)
      # Check if payment was ok
      raise OrderCanceled,      "Payment canceled by customer"                 if params[:vads_result]  == "17"        # Annulation par client
      raise ReturnCode,         "Wrong return code : #{params[:vads_result]}"  unless params[:vads_result] == "00"        # code de retour, "00" = "tout s'est bien passé" 
      raise PaymentCertificate, "No payment certificate"                       if params[:vads_payment_certificate] == "" # Pas de certificat = probleme
      raise AuthMode,           "Wrong auth mode : #{params[:vads_auth_mode]}" if params[:vads_auth_mode] != "FULL"       # Autorisation du paiement 
      
      # Check if the signature is valid    
      raise Signature, "Wrong signature" if params[:signature] != compute_signature(params) 
      return true  
    end
    
    def self.check_conformity_between(order, params)
      raise InvalidAmount unless (params[:vads_currency] == "978") and ((order.total * 100).to_i.to_s == params[:vads_amount])
    end

   # private
    
    #creates a hash containing all payzen parameters
    def payzen_param_hash
      hash = Hash.new
      PayzenIntegration::Params::PARAMS.each do |p|
        hash[p] = self.send(p)
      end
      hash
    end
    
    # Compute a signature from a hash
    def self.compute_signature(hash)
      Digest::SHA1.hexdigest create_string_from_config_hash hash
    end
    
    # only akes into account the keys beginning with vads
    def self.create_string_from_config_hash(hash)
      to_code = String.new
      hash.stringify_keys!.keys.sort.each do |key|
        to_code = to_code + hash[key].to_s + "+" if key.to_s =~ /^vads*/
      end
      to_code += (PayzenIntegration::Config.get :certificate).to_s
    end

    # Compute the trans_date attribute
    def self.trans_date # doit retourner AAAAMMJJHHMMSS
      date = Time.now
      date.strftime('%Y%m%d%H%M%S') # Renvoie AAAAMMJJHHMMSS
    end
    
    def self.trans_id
      date = Time.now
      date.strftime('%H%M%S') # Renvoie HHMMSS
    end
  end

end