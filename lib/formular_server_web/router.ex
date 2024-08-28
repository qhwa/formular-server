defmodule Formular.ServerWeb.Router do
  use Formular.ServerWeb, :router

  import Formular.ServerWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  import Plug.BasicAuth

  forward "/health/live", Healthchex.Probes.Liveness
  forward "/health/ready", Healthchex.Probes.Readiness

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {Formular.ServerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :protected do
    plug :require_authenticated_user
  end

  pipeline :developer do
    plug :basic_auth, username: "formular-server", password: "looS5ash"
  end

  pipeline :api do
    plug :accepts, ["*/*"]
    plug Formular.ServerWeb.Plug.ApiAuth
  end

  scope "/", Formular.ServerWeb do
    pipe_through [:browser, :protected]

    live "/", FormulaLive.Index, :index
    live "/formulas/new", FormulaLive.New, :new

    live "/formulas/:name", FormulaLive.Show, :show
    live "/formulas/:name/edit", FormulaLive.Edit, :edit
    live "/formulas/:name/revisions/:id", FormulaLive.Show, :show_rev
  end

  scope "/auth", Formular.ServerWeb do
    pipe_through [:browser]

    get "/:provider", UserOauthController, :request
    get "/:provider/callback", UserOauthController, :callback
  end

  scope "/dev" do
    pipe_through [:browser, :developer]
    live_dashboard "/dashboard"
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", Formular.ServerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", Formular.ServerWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", Formular.ServerWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/users/confirm", UserConfirmationController, :new
    post "/users/confirm", UserConfirmationController, :create
    get "/users/confirm/:token", UserConfirmationController, :edit
    post "/users/confirm/:token", UserConfirmationController, :update
  end

  scope "/api", Formular.ServerWeb.Api do
    pipe_through :api

    post "/run/:name", ComputationController, :create
    post "/rules/:name", RuleController, :index
    patch "/rules/:name", RuleController, :update

    post "/formulas/:formula_name/revisions", RevisionController, :create
  end
end
