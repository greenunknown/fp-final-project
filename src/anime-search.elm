-- Anime Search

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)

-- MAIN


-- main =
--   Browser.sandbox { init = init, update = update, view = view }

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- MODEL


-- type alias Model =
--   { content : String
--   }


-- init : Model
-- init =
--   { content = "" }

type alias Status = Failure
  | Loading
  | Success String

type Model = 
  { content: String
  , status : Status
  }
  


init : () -> (Model, Cmd Msg)
init _ =
  ( { Loading, content = "" }
  , Http.get
      { url = "https://elm-lang.org/assets/public-opinion.txt"
      , expect = Http.expectString GotText
      }
  )


-- UPDATE


-- type Msg
--   = Change String


update : Msg -> Model -> Model
update msg model =
  case msg of
    Change newContent ->
      { model | content = newContent }

type Msg
  = Change String 
  | GotText (Result Http.Error String)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotText result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

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
    [ input [ placeholder "Anime to search", value model.content, onInput Change ] []
    , div [] [ text ("https://api.jikan.moe/v3/search/anime?q='"++ model.content ++ "'") ]
    ]

view : Model -> Html Msg
view model =
  case model.status of
    Failure ->
      div []
        [ text "Status: I was unable to load your book."
        , input [ placeholder "Anime to search", value model.content, onInput Change ] []
        , div [] [ text ("https://api.jikan.moe/v3/search/anime?q='"++ model.content ++ "'") ]
        ]

    Loading ->
      div []
        [ text "Status: Loading..."
        , input [ placeholder "Anime to search", value model.content, onInput Change ] []
        , div [] [ text ("https://api.jikan.moe/v3/search/anime?q='"++ model.content ++ "'") ]
        ]

    Success data ->
      -- pre [] [ text fullText ]
      div []
        [ text "Status: I was unable to load your book."
        , input [ placeholder "Anime to search", value model.content, onInput Change ] []
        , div [] [ text ("https://api.jikan.moe/v3/search/anime?q='"++ model.content ++ "'") ]
        ]

-- HTTP

searchAnime : Model -> Cmd Msg
searchAnime model = Http.get
      { url = crossOrigin "https://kitsu.io/api/edge/anime" [model.content] []
      , expect = Http.expectJson GotImg animeDecoder
      }

animeSearchDecoder : Decoder String
animeSearchDecoder = 






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
  (Loading, getRandomCatGif)



-- UPDATE


type Msg
  = MorePlease
  | GotGif (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (Loading, getRandomCatGif)

    GotGif result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)






-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Cats" ]
    , viewGif model
    ]


viewGif : Model -> Html Msg
viewGif model =
  case model of
    Failure ->
      div []
        [ text "I could not load a random cat for some reason. "
        , button [ onClick MorePlease ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success url ->
      div []
        [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
        , img [ src url ] []
        ]



-- HTTP


getRandomCatGif : Cmd Msg
getRandomCatGif =
  Http.get
    { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=cat"
    , expect = Http.expectJson GotGif gifDecoder
    }


gifDecoder : Decoder String
gifDecoder =
  field "data" (field "image_url" string)