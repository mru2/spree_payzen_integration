module PayzenIntegration

  # Wrapper for the .yml config
  class Config
    
    # Dynamic methods
    def self.get(key)
      conf_file[key.to_s] # Will load the file if not loaded, and look for the corresponding field
    end
    
    private
    
    def self.conf_file
      @conf_file ||= YAML.load_file("#{Rails.root}/config/payzen.yml")
    end
    
  end
  
end
    
