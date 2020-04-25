module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, input, span, text)
import Html.Attributes exposing (class, href, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode as D exposing (Decoder, list, map2, field)
import Url
import Url.Parser exposing (Parser, (<?>), map, oneOf, parse, s, top)
import Url.Parser.Query as Query



-- MAIN

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }



-- MODEL

type Route
  = Index
  | About
  | IngredientSearch (Maybe String)
  | NotFound

type alias Model =
  { content : String
  , error : Maybe (Http.Error)
  , ingredients : List Ingredient
  , key : Nav.Key
  , route : Route
  , url : Url.Url
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
  let route = fromUrl url
  in ( Model "" Nothing [] key route url, Cmd.none )



-- UPDATE

type Msg
  = FoundIngredients (Result Http.Error (List Ingredient))
  | LinkClicked Browser.UrlRequest
  | SearchIngredient
  | UpdateContent String
  | UrlChanged Url.Url

routeParser : Parser (Route -> a) a
routeParser =
  oneOf
    [ map Index   top
    , map About   (s "about")
    , map IngredientSearch (s "ingredients" <?> Query.string "q")
    ]

fromUrl : Url.Url -> Route
fromUrl url =
    Maybe.withDefault NotFound (parse routeParser url)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FoundIngredients result ->
      case result of
        Ok ingredients ->
          ( { model | error = Nothing, ingredients = ingredients }, Nav.pushUrl model.key ("/ingredients?q=" ++ model.content) )
        Err error ->
          ( { model | error = Just error, ingredients = [] }, Cmd.none)

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    SearchIngredient -> (model, searchIngredients model.content)

    UpdateContent content ->
      ( { model
        | content = content
        }
      , Cmd.none
      )

    -- My guess is that we need to do a case statement and
    -- run the query as a Cmd (searchIngredients model.content - see above)
    -- when the route is SearchIngredients or whatever.
    UrlChanged url ->
      ( { model
        | route = fromUrl url
        , url = url
        }
      , Cmd.none
      )



-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



-- VIEW

view : Model -> Browser.Document Msg
view model =
  { title = "My Food Is What?!"
  , body =
    [ div
      [ class "container justify-content-center align-items-center text-center min-vh-100"
      , style "font-family" "Georgia"
      ]
      [ div [ style "padding" "15px 0 5px 0" ] [ h1 [ class "col-12" ] [ text "My Food Is What?!" ] ]
      , div [] (currentView model)
      ]
    ]
  }

currentView : Model -> List (Html Msg)
currentView model =
  let
    viewFromRoute =
      case model.route of
        Index -> indexView
        About -> aboutView
        IngredientSearch _ -> ingredientSearchView
        NotFound -> notFoundView
  in viewFromRoute model

indexView : Model -> List (Html Msg)
indexView model =
  [ div [ class "row text-center align-items-center w-100"
    ]
    [ div [ class "col-12" ]
      [ span []
        [ input [ placeholder "Enter an ingredient...", value model.content, onInput UpdateContent ] []
        , button [ onClick SearchIngredient ] [ text "Search" ]
        , div [] [ text "Try searching for an ingredient." ]
        , viewLink "/about" "Learn more"
        ]
      ]
    ]
  ]

showSearchResult : List Ingredient -> Html Msg
showSearchResult ingredients =
  case ingredients of
    [] -> div [] [ text "No results found." ]
    (x :: _) -> div [] [ text (x.name ++ ": " ++ x.description) ]

showSearchError : Maybe (Http.Error) -> Html Msg
showSearchError error =
  let
    errorText =
      case error of
        Nothing -> ""
        Just (BadUrl url) -> "Bad URL: " ++ url
        Just (Timeout) -> "Timeout"
        Just (NetworkError) -> "Network error"
        Just (BadStatus status) -> "Bad status: " ++ String.fromInt status
        Just (BadBody body) -> "Bad body: " ++ body
  in text errorText

showTitle : Route -> String
showTitle route =
  case route of
    Index ->    "Index"
    About ->    "About"
    IngredientSearch _ -> "Search"
    NotFound -> "Not Found"

viewLink : String -> String -> Html msg
viewLink path content =
  div [] [ a [ href path ] [ text content ] ]

aboutView : Model -> List (Html Msg)
aboutView _ =
  [ div [] [ text "We want to help people to understand the ingredients on their foods' nutrition labels." ]
  , div [] [ text "See an ingredient with which you're unfamiliar? Try searching for it to learn more!" ]
  , div [] [ viewLink "/" "Return to Home Page" ]
  ]

ingredientSearchView : Model -> List (Html Msg)
ingredientSearchView model = [
  div []
    [ text ("Searched for " ++ model.content)
    , showSearchResult model.ingredients
    , showSearchError model.error ] ]

notFoundView : Model -> List (Html Msg)
notFoundView _ =
  [ div []
    [ text "Sorry, but that page does not exist."
    , viewLink "/" "Return to Home Page"
    ]
  ]

-- HTTP

searchIngredients : String -> Cmd Msg
searchIngredients query =
  Http.get
    { url = "http://localhost:4000/api/ingredients?search=" ++ query
    , expect = Http.expectJson FoundIngredients searchIngredientsDecoder
    }

type alias Ingredient =
  { name : String
  , description : String
  }

ingredientDecoder : Decoder Ingredient
ingredientDecoder =
  map2 Ingredient (field "name" D.string) (field "description" D.string)

searchIngredientsDecoder : Decoder (List Ingredient)
searchIngredientsDecoder = field "data" (list ingredientDecoder)