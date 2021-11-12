defmodule TriadApi.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :TriadApi,
    module: TriadApi.Guardian,
    error_handler: TriadApi.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
