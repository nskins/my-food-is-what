defmodule MfiwWeb.PageController do
  use MfiwWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
