module Main exposing (..)

import Browser
import Html exposing (Html, text)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { field : String }


-- INIT


init : Model
init =
    { field = "value" }



-- MESSAGE


type Msg
    = Hi String


-- UPDATE


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Html Msg
view model =
    text "Hello World"
