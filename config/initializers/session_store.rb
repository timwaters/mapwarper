  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  ActionController::Base.session = {
    :session_key => '_mapwarper_session',
    :secret      => '7330c126d3dd868dbb72710ecb91fa324df40dea89dcdda744b2a4cfe3e9c455c651c261b482e001ac39bec59a3b8dd1c6e8806cbf133'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
