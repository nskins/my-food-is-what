defmodule MfiwWeb.ErrorView do
  use MfiwWeb, :view

  def render("400.json", _assigns) do
    %{errors: %{message: "Bad Request"}}
  end

  def render("404.json", _assigns) do
    %{errors: %{message: "Not Found"}}
  end

  def render("500.json", _assigns) do
    %{errors: %{message: "Server Error"}}
  end
end
