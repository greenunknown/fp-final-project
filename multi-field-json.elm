-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string, map2)



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
    | Success GifObj

type alias GifObj =
  { id : String
  , imageUrl : String
  }
  

type alias Model = 
  { status : Status
  , gifobj : GifObj
  }


init : () -> (Model, Cmd Msg)
init _ =
--   (Loading, getRandomCatGif)
    -- ({status = Loading, gifobj = {id = "", imgUrl = ""}}, getRandomCatGif)
    ({status = Loading, gifobj = {id = "", imageUrl = ""}}, getRandomCatGif {status = Loading, gifobj = {id = "", imageUrl = ""}})



-- UPDATE


type Msg
  = MorePlease
  | GotGif (Result Http.Error GifObj)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
    --   (Loading, getRandomCatGif)
        -- let (newGif, cmd) = getRandomCatGif model in (newGif, cmd)
      ({status = Loading, gifobj = {id = "", imageUrl = ""}}, getRandomCatGif model)
    GotGif result ->
      case result of
        Ok url ->
        --   (Success url, Cmd.none)
            ({status = Success url, gifobj = model.gifobj}, Cmd.none)

        Err _ ->
        --   (Failure, Cmd.none)
            ({status = Failure, gifobj = model.gifobj}, Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Random Cats" ]
    , viewGif model
    ]


viewGif : Model -> Html Msg
viewGif model =
  case model.status of
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
        , h2 [] [text url.id]
        , img [src url.imageUrl] []
        -- , viewGifObj model.gifobj
        --, img [ src url ] []
        ]



-- HTTP


getRandomCatGif : Model -> Cmd Msg
getRandomCatGif model =
  Http.get
    { url = "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=cat"
    , expect = Http.expectJson GotGif gifDecoder
    }


--gifDecoder : Decoder String
--gifDecoder =
--  field "data" (field "image_url" string)

gifDecoder : Decoder GifObj
gifDecoder =
  map2 GifObj
    (field "data" (field "id" string))
    (field "data" (field "image_url" string))


-- viewGifObj : GifObj -> Html Msg
-- viewGifObj gifobj =
--   div []
--      [h2 [] [text gifobj.id]
--      , img [src gifobj.imageUrl] []
--      ]

--  decodeString (field "data" (field "image_url" string))
--  decodeString (field "data" (field "id" string))

