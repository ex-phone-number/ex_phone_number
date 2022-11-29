import Config

config :logger,
  backends: [:console]

import_config "#{Mix.env()}.exs"
