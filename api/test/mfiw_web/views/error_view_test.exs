defmodule MfiwWeb.ErrorViewTest do
  use MfiwWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 400.json" do
    assert render(MfiwWeb.ErrorView, "400.json", []).errors.message == "Bad Request"
  end

  test "renders 404.json" do
    assert render(MfiwWeb.ErrorView, "404.json", []).errors.message == "Not Found"
  end

  test "renders 500.json" do
    assert render(MfiwWeb.ErrorView, "500.json", []).errors.message == "Server Error"
  end
end
