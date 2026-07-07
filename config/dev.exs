import Config

config :ex_phone_number,
  log_level: :debug,
  debug_log: System.get_env("DEBUG") in ["true", "1", "yes"]
