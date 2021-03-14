module Main exposing (..)

import Html exposing (beginnerProgram, button, div, text)
import Html.Events exposing (onClick)

-- Initial state
initModel = 0

-- Actions our app supports
type Msg = Increment | Decrement  -- Think of this like labels


-- Receive a msg and the current model and determine what to do
--  to create the new model.
-- Place where all logic for elm app sits
update msg model =
    case msg of
        Increment ->
            model + 1
        Decrement ->
            model - 1


-- Receives a model and returns markup
view model =
    div [] -- divider has no attributes as it's first argument and contents as its second arg
        [ button [ onClick Decrement ] [text "-"]
        , div [] [ text (toString model)]
        , button [ onClick Increment ] [ text "+"]
        ]

-- elm entry point

main = beginnerProgram { model = model, view = view, update = update}
    -- mode is state, view is view, update is update