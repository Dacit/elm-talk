module Main exposing (..)

import Browser
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onEnter)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Todo =
    { done : Bool
    , title : String
    , desc : String
    }


type alias Model =
    { todos : List Todo
    , createTitle : String
    , createDesc : String
    }



-- INIT


init : Model
init =
    Model
        [ Todo True "Hello world" "Write hello world app"
        , Todo False "Todo" "Write todo app"
        ]
        ""
        ""



-- MESSAGE


type Msg
    = UpdateTodo Int Todo
    | UpdateTitle String
    | UpdateDesc String
    | CreateTodo



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateTodo i todo ->
            { model | todos = List.take i model.todos ++ [ todo ] ++ List.drop (i + 1) model.todos }

        UpdateTitle title ->
            { model | createTitle = title }

        UpdateDesc title ->
            { model | createDesc = title }

        CreateTodo ->
            { model | todos = model.todos ++ [ Todo False model.createTitle model.createDesc ] }



-- VIEW


viewTodo : (Todo -> Msg) -> Todo -> Html Msg
viewTodo toMsg todo =
    div []
        [ label []
            [ input [ type_ "checkbox", onClick <| toMsg { todo | done = not todo.done } ] []
            , text <| todo.title ++ ": " ++ todo.desc
            ]
        ]


inputField hint val onInp onEnt =
    input
        [ type_ "text"
        , placeholder hint
        , value val
        , onInput onInp
        , onEnter onEnt
        ]
        []


view : Model -> Html Msg
view model =
    div [] <|
        List.indexedMap (viewTodo << UpdateTodo) model.todos
            ++ [ div []
                    [ inputField "title" model.createTitle UpdateTitle CreateTodo
                    , inputField "description" model.createDesc UpdateDesc CreateTodo
                    , button [ onClick CreateTodo ] [ text "+" ]
                    ]
               ]
