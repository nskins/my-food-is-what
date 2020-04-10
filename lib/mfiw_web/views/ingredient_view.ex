defmodule MfiwWeb.IngredientView do
  use MfiwWeb, :view
  alias MfiwWeb.IngredientView

  def render("index.json", %{ingredients: ingredients}) do
    %{data: render_many(ingredients, IngredientView, "ingredient.json")}
  end

  def render("show.json", %{ingredient: ingredient}) do
    %{data: render_one(ingredient, IngredientView, "ingredient.json")}
  end

  def render("ingredient.json", %{ingredient: ingredient}) do
    %{id: ingredient.id,
      name: ingredient.name,
      description: ingredient.description}
  end
end
