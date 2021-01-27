module Main exposing (..)

import Browser
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (checked, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Html.Events.Extra exposing (onEnter)
import Todo exposing (Todo)



-- MAIN


main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }



-- MODEL


type alias Model =
    { todos : List Todo
    , create : String
    }



-- INIT


backend =
    "https://todo-backend-akka.herokuapp.com/todos"


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model [] ""
    , Todo.list backend LoadedTodos
    )



-- MSG


type Msg
    = DeleteTodo Int Todo
    | UpdateCreate String
    | CreateTodo
    | LoadedTodos (List Todo)
    | LoadTodos



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DeleteTodo i todo ->
            ( { model | todos = List.take i model.todos ++ [ todo ] ++ List.drop (i + 1) model.todos }
            , Todo.delete LoadTodos todo
            )

        UpdateCreate input ->
            ( { model | create = input }, Cmd.none )

        CreateTodo ->
            ( { model | create = "" }, Todo.create backend model.create LoadTodos )

        LoadedTodos todos ->
            ( { model | todos = todos }, Cmd.none )

        LoadTodos ->
            ( model, Todo.list backend LoadedTodos )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions =
    always Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div [] <|
        List.indexedMap (Todo.view << DeleteTodo) model.todos
            ++ [ div []
                    [ input
                        [ type_ "text"
                        , placeholder "todo"
                        , value model.create
                        , onInput UpdateCreate
                        , onEnter CreateTodo
                        ]
                        []
                    , button [ onClick CreateTodo ] [ text "+" ]
                    ]
               ]
