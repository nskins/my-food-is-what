module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, button, div, h1, input, span, text)
import Html.Attributes exposing (class, href, placeholder, style, value)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode exposing (Decoder, list, map2, field, string)
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)



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
  | Contact
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
    , map Contact (s "contact")
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
          ( { model | error = Nothing, ingredients = ingredients }, Cmd.none)
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
        [ class "container justify-content-center align-items-center min-vh-100"
        , style "font-family" "Georgia"
        ]
        [ div
          [ class "row text-center align-items-center w-100"
          ]
          [ h1 [ class "col-12" ] [ text "My Food Is What?!" ]
          , div [ class "col-12" ] [ text "Everything you need to know about 'Other Ingredients'" ]
          ]
        , div [ class "row text-center align-items-center w-100"
          ]
          [ div [ class "col-12" ]
            [ span []
              [ input [ placeholder "Enter an ingredient...", value model.content, onInput UpdateContent ] []
              , button [ onClick SearchIngredient ] [ text "Search" ]
              , if model.route == Index then viewLink About "/about" else viewLink Index "/" ]
            ]
          , div [ class "col-12" ]
            [ showSearchResult model.ingredients
            , showSearchError model.error ]
          ]
        ]
      ]

  }

showSearchResult : List Ingredient -> Html Msg
showSearchResult ingredients =
  case ingredients of
    [] -> text "Nothing"
    (x :: _) -> text x.description

showSearchError : Maybe (Http.Error) -> Html Msg
showSearchError error =
  case error of
    Nothing -> text ""
    Just (BadUrl url) -> text ("Bad URL: " ++ url)
    Just (Timeout) -> text "Timeout"
    Just (NetworkError) -> text "Network error"
    Just (BadStatus status) -> text ("Bad status: " ++ String.fromInt status)
    Just (BadBody body) -> text ("Bad body: " ++ body)



showTitle : Route -> String
showTitle route =
  case route of
    Index ->    "Index"
    About ->    "About"
    Contact ->  "Contact"
    NotFound -> "Not Found"

viewLink : Route -> String -> Html msg
viewLink route path =
  div [] [ a [ href path ] [ text (showTitle route) ] ]


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
  map2 Ingredient (field "name" string) (field "description" string)

searchIngredientsDecoder : Decoder (List Ingredient)
searchIngredientsDecoder = field "data" (list ingredientDecoder)