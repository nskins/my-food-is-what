defmodule MfiwWeb.IngredientController do
  use MfiwWeb, :controller

  alias Mfiw.Ingredients
  alias Mfiw.Ingredients.Ingredient

  action_fallback MfiwWeb.FallbackController

  def index(conn, params) do
    search_query = Map.get(params, "search")
    ingredients = case search_query do
      nil -> Ingredients.list_ingredients()
      ingredient_name -> Ingredients.get_ingredients_by_name!(ingredient_name)
    end
    render(conn, "index.json", ingredients: ingredients)
  end

  def create(conn, %{"ingredient" => ingredient_params}) do
    with {:ok, %Ingredient{} = ingredient} <- Ingredients.create_ingredient(ingredient_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.ingredient_path(conn, :show, ingredient))
      |> render("show.json", ingredient: ingredient)
    end
  end

  def show(conn, %{"id" => id}) do
    ingredient = Ingredients.get_ingredient!(id)
    render(conn, "show.json", ingredient: ingredient)
  end

  def update(conn, %{"id" => id, "ingredient" => ingredient_params}) do
    ingredient = Ingredients.get_ingredient!(id)

    with {:ok, %Ingredient{} = ingredient} <- Ingredients.update_ingredient(ingredient, ingredient_params) do
      render(conn, "show.json", ingredient: ingredient)
    end
  end

  def delete(conn, %{"id" => id}) do
    ingredient = Ingredients.get_ingredient!(id)

    with {:ok, %Ingredient{}} <- Ingredients.delete_ingredient(ingredient) do
      send_resp(conn, :no_content, "")
    end
  end
end
