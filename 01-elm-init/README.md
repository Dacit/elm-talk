# Elm-Init

Neues Elm Projekt:
``elm init``

Dann: `src/Main.elm` anlegen. Inhalt:
```elm
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

```
Das ist ein Hello World mit ein bisschen Zusatz.

## Ausführen
1. `elm reactor` (kein CSS, kein hot-reloading, baut nur .elm file). Äquivalent zu:
   - `elm make src/Main.elm`, erzeugte `index.html` im browser öffnen
2. Einbetten in html: (hier mit bootstrap css): `index.html` anlegen:
    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <!-- Required meta tags -->
        <meta charset="utf-8">
        <meta content="width=device-width, initial-scale=1, shrink-to-fit=no" name="viewport">
        <title>Elm App</title>
        <!-- Bootstrap CSS -->
        <link crossorigin="anonymous" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css"
              integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" rel="stylesheet">
        <!-- Compiled Elm -->
        <script src="main.js"></script>
    </head>
    <body>
    <!-- Elm application  -->
    <div id="app"></div>
    <script>Elm.Main.init({node: document.getElementById('app')});</script>
    </body>
    </html>
    ```
   1. Per Hand: Nach JS compilieren: `elm make src/Main.elm --output=main.js`, dann mit beliebigen Webserver bereitstellen
   2. Mit `elm-live` (optional am Ende `--debug`):
      ```
      elm-live src/Main.elm --open --start-page=index.html -- --output=main.js
      ```