-- Press a button to send a GET request for random anime.

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, map2, field, string)
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


-- type Model
--   = Failure
--   | Loading
--   | Success String

type Status
  = Failure
    | Loading
    | Success String

type alias Model = 
  { status : Status
  , seed : Random.Seed
  }


-- init : () -> (Model, Cmd Msg)
-- init _ =
--   (Loading, gotRandomAnime)

init : () -> (Model, Cmd Msg)
init _ =
  -- ({status = Loading, seed = Random.initialSeed 0}, gotRandomAnime {status = Loading, seed = Random.initialSeed 0})
  let (newSeed, cmd) = gotRandomAnime {status = Loading, seed = Random.initialSeed 0} in (newSeed, cmd)

-- UPDATE


type Msg
  = MorePlease
  | GotImg (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      -- ({status = Loading, seed = model.seed}, gotRandomAnime model)
      let (newSeed, cmd) = gotRandomAnime model in (newSeed, cmd)

    GotImg result ->
      case result of
        Ok url ->
          ({status = Success url, seed = model.seed}, Cmd.none)

        Err _ ->
          ({status = Failure, seed = model.seed}, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Anime" ]
    , viewImg model
    ]


viewImg : Model -> Html Msg
viewImg model =
  case model.status of
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
        , div [] [ text url.title]
        , img [ src url.image ] []
        ]



-- HTTP

-- Random help from Augustin82 and wolfadex: https://discourse.elm-lang.org/t/convert-random-int-to-string-for-use-in-url-builder/7081/3
roll : Random.Generator Int
roll = 
  Random.int 1 600 -- 10509 is an experimental upper limit of the number of anime

randomIntToString : Random.Generator Int -> Random.Generator String --Random.Generator String
randomIntToString randomInt =
    Random.map String.fromInt randomInt

gotRandomAnime : Model -> (Model, Cmd Msg)
gotRandomAnime model =
  let
    ( randStr, nextSeed ) =
        Random.step (randomIntToString roll) model.seed
  in
  ( { model | seed = nextSeed }
  , Http.get
      { url = crossOrigin "https://www.cheapshark.com/api/1.0" [("games?id=" ++ randStr)] []
      , expect = Http.expectJson GotImg animeDecoder
      }
  )


type alias Game = 
  {
    title : String
  , image : String
  }

animeDecoder : Decoder String
animeDecoder =
  map2 String 
    (field "info" (field "title" Json.Decode.string))
    (field "info" (field "thumb" Json.Decode.string))