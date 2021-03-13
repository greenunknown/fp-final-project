-- Press a button to send a GET request for random anime.
-- Author: Brandon Le
-- Contributions: 
--  Instructor Casamento
--  Help with random from Augustin82 and wolfadex: 
--    https://discourse.elm-lang.org/t/convert-random-int-to-string-for-use-in-url-builder/7081/3
--  

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string, map2)
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


type Status
  = Failure
    | Loading
    | Success AnimeObj

type alias AnimeObj =
  { id : String
  , imageUrl : String
  }

type alias Model = 
  { status : Status
  , animeObj : AnimeObj
  , seed : Random.Seed
  }


init : () -> (Model, Cmd Msg)
init _ =
  let (newSeed, cmd) = getRandomAnime {status = Loading, animeObj = {id = "", imageUrl = ""}, seed = Random.initialSeed 0} in (newSeed, cmd)

-- UPDATE


type Msg
  = MorePlease
  | GotImg (Result Http.Error AnimeObj)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      let (newSeed, cmd) = getRandomAnime model in (newSeed, cmd)

    GotImg result ->
      case result of
        Ok url ->
          ({status = Success url, animeObj = model.animeObj, seed = model.seed}, Cmd.none)

        Err _ ->
          ({status = Failure, animeObj = model.animeObj, seed = model.seed}, Cmd.none)



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
        [ text "I could not load a random anime for some reason. 😅"
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "Randomize" ]
        , h2 [] [text url.id]
        , img [ src url.imageUrl ] []
        ]



-- HTTP

roll : Random.Generator Int
roll = 
  Random.int 1 6--14267 is an experimental upper limit of the number of anime

randomIntToString : Random.Generator Int -> Random.Generator String --Random.Generator String
randomIntToString randomInt =
    Random.map String.fromInt randomInt

getRandomAnime : Model -> (Model, Cmd Msg)
getRandomAnime model =
  let
    ( randStr, nextSeed ) =
        Random.step (randomIntToString roll) model.seed
  in
  ( { model | seed = nextSeed }
  , Http.get
      -- { url = crossOrigin "https://api.jikan.moe/v3/anime" [randStr] []
      { url = crossOrigin "https://kitsu.io/api/edge/anime" [randStr] []
      , expect = Http.expectJson GotImg animeDecoder
      }
  )

animeDecoder : Decoder AnimeObj
animeDecoder =
  map2 AnimeObj
    (field "data" (field "attributes" (field "titles" (field "en" Json.Decode.string))))
    (field "data" (field "attributes" (field "posterImage" (field "medium" Json.Decode.string))))