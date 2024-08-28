import Config

config :ueberauth, Ueberauth,
  providers: [
    okta: {Ueberauth.Strategy.Okta, []},
    github: {Ueberauth.Strategy.Github, []},
    keycloak: {Ueberauth.Strategy.Keycloak, [default_scope: "profile email roles"]},
    google: {Ueberauth.Strategy.Google, []}
  ]

config :ueberauth, Ueberauth.Strategy.Keycloak.OAuth,
  client_id: System.get_env("KEYCLOAK_CLIENT_ID"),
  client_secret: System.get_env("KEYCLOAK_CLIENT_SECRET"),
  redirect_uri: System.get_env("KEYCLOAK_REDIRECT_URI"),
  authorize_url: "http://localhost:8080/realms/master/protocol/openid-connect/auth",
  token_url: "http://localhost:8080/realms/master/protocol/openid-connect/token",
  userinfo_url: "http://localhost:8080/realms/master/protocol/openid-connect/userinfo"

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :formular_server, :oauth_strategies, ~w[google]
