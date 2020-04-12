defmodule Mfiw.Repo do
  use Ecto.Repo,
    otp_app: :mfiw,
    adapter: Ecto.Adapters.Postgres
end
