module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, a, div, h1, text)
import Html.Attributes exposing (class, href, style)
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
  { key : Nav.Key
  , route : Route
  , url : Url.Url
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
  let route = fromUrl url
  in ( Model key route url, Cmd.none )



-- UPDATE

type Msg
  = LinkClicked Browser.UrlRequest
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
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

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
            [ if model.route == Index then viewLink About "/about" else viewLink Index "/" ]
          ]
        ]
      ]

  }

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