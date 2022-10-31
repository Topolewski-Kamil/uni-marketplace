Airbrake.configure do |config|
    config.api_key = 'c5c33f1a9fd9066ea458ceae621d8de5'
    config.host    = 'errbit.hut.shefcompsci.org.uk'
    config.port    = 443
    config.secure  = config.port == 443
  end