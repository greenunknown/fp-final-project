-- Press a button to send a GET request for random anime.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)
import Random
import Url.Builder exposing
  ( absolute, relative, crossOrigin, custom, Root(..)
  , QueryParameter, string, int, toQuery
  )

-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type Model
  = Failure
  | Loading
  | Success String


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, gotRandomAnime)



-- UPDATE


type Msg
  = MorePlease
  | GotImg (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (Loading, gotRandomAnime)

    GotImg result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Anime" ]
    , viewGif model
    ]


viewGif : Model -> Html Msg
viewGif model =
  case model of
    Failure ->
      div []
        [ text "I could not load a random anime for some reason. "
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "Randomize" ]
        , img [ src url ] []
        ]



-- HTTP

-- randomAnime = Random.int 1 10509 -- 10509 is an experimental upper limit of the number of anime
-- seed0 = Random.initialSeed 42

roll : Random.Generator Int
roll = 
  Random.int 1 6

gotRandomAnime : Cmd Msg
gotRandomAnime =
  Http.get
    { url = crossOrigin "https://api.jikan.moe/v3/anime/" [roll] []
    , expect = Http.expectJson GotImg animeDecoder
    }


animeDecoder : Decoder String
animeDecoder =
  -- field "data" (field "image_url" string)
  field "image_url" Json.Decode.string
  -- field "top" (field "image_url" string)