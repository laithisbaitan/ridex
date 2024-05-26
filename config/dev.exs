import Config

# Configure your database
config :ridex, Ridex.Repo,
  # username: "postgres",
  # password: "v3rys3cure",
  # hostname: "localhost",
  # database: "ridex_dev",
  # stacktrace: true,
  # show_sensitive_data_on_connection_error: true,
  # pool_size: 10
  username: "8cd04f56-6751-42ae-83bd-f83529693307-user",
  password: "pw-4ff25b92-80ab-45ff-94d3-4bec95386627",
  hostname: "postgres-free-tier-v2020.gigalixir.com",
  database: "8cd04f56-6751-42ae-83bd-f83529693307",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we can use it
# to bundle .js and .css sources.
config :ridex, RidexWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "NeVUHwCz03GwWfO8IW68YOUFqT1JH+r3lq6eM0rzAk1QQqZ9vbgIeA6fWYPt2vek",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:ridex, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:ridex, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :ridex, RidexWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/ridex_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :ridex, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Include HEEx debug annotations as HTML comments in rendered markup
config :phoenix_live_view, :debug_heex_annotations, true

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
