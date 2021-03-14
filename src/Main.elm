-- Press a button to send a GET request for a random anime.
-- Author: Brandon Le
-- Contributions: 
--  Instructor Casamento for help on the randomize mechanism and general Elm help
--  Help with random from Augustin82 and wolfadex: 
--    https://discourse.elm-lang.org/t/convert-random-int-to-string-for-use-in-url-builder/7081/3
--  Http error to string by bdukes
--    https://stackoverflow.com/questions/56442885/error-when-convert-http-error-to-string-with-tostring-in-elm-0-19

module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string, map2, map3, map4)
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
  = Failure String
    | Loading
    | Success AnimeObj

type alias AnimeObj =
  { id : String 
  , title : String
  , imageUrl : String
  , description : String
  }

type alias Model = 
  { status : Status
  , animeObj : AnimeObj
  , seed : Random.Seed
  }


init : () -> (Model, Cmd Msg)
init _ =
  let (newSeed, cmd) = getRandomAnime {status = Loading, animeObj = {id = "", title = "", imageUrl = "", description = ""}, seed = Random.initialSeed 0} in (newSeed, cmd)

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

        Err err ->
          ({status = Failure (errorToString err), animeObj = model.animeObj, seed = model.seed}, Cmd.none)


errorToString : Http.Error -> String
errorToString error =
    case error of
        Http.BadUrl url ->
            "The URL " ++ url ++ " was invalid"
        Http.Timeout ->
            "Unable to reach the server, try again"
        Http.NetworkError ->
            "Unable to reach the server, check your network connection"
        Http.BadStatus 500 ->
            "The server had a problem, try again later"
        Http.BadStatus 400 ->
            "Verify your information and try again"
        Http.BadStatus _ ->
            "Unknown error"
        Http.BadBody errorMessage ->
            errorMessage

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text "Random Anime" ]
    , viewImg model
    ]


viewImg : Model -> Html Msg
viewImg model =
  case model.status of
    Failure err ->
      div []
        [ text ("I could not load a random anime for some reason. You've found an empty entry! 😅 \nError: " ++ err)
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        , img [ src "sadness.gif"] []
        , text "Image Source: https://giphy.com/gifs/japan-crying-3ov9jUBdDA5FFFITOU"
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "Randomize" ]
        , text ("Anime ID: " ++ url.id)
        , h2 [] [ text url.title ]
        , img [ src url.imageUrl ] []
        , text url.description
        ]



-- HTTP

roll : Random.Generator Int
roll = 
  Random.int 1 14267 -- an experimental upper limit of the number of anime

randomIntToString : Random.Generator Int -> Random.Generator String
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
      { url = crossOrigin "https://kitsu.io/api/edge/anime" [randStr] []
      , expect = Http.expectJson GotImg animeDecoder
      }
  )

animeDecoder : Decoder AnimeObj
animeDecoder =
  map4 AnimeObj
    (field "data" (field "id" Json.Decode.string))
    (field "data" (field "attributes" (field "canonicalTitle" Json.Decode.string)))
    (field "data" (field "attributes" (field "posterImage" (field "medium" Json.Decode.string))))
    (field "data" (field "attributes" (field "description" Json.Decode.string)))
