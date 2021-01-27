# Patterns and Effects
Unsere Todo-app ist noch sehr klein und übersichtlich.
Aber sollte sie weiter wachsen, wollen wir vielleicht die Todo creation auslagern.
Naiver approach:
```elm
type alias TodoCreate = 
    { title: String
    , desc: String
    }

type alias Model =
    { todos: List Todo
    , create: TodoCreate
    }


init = ...
    <|
        TodoCreate "" ""


type CreateMsg
    = UpdateTitle String
    | UpdateDesc String


type Msg
    = UpdateTodo Int Todo
    | CreateMsg CreateMsg
    | CreateTodo
```
Jetzt können wir eine Render-Funktion nur für `CreateTodo` bauen:
```elm
viewCreate : TodoCreate -> Html Msg
viewCreate create =
    div []
        [ input [ type_ "text", placeholder "title", value <| create.title, onInput (CreateMsg << UpdateTitle) ] []
        , input [ type_ "text", placeholder "description", value create.desc, onInput (CreateMsg << UpdateDesc) ] []
        , button [ onClick CreateTodo ] [ text "+" ]
        ]

view model =
    ...
            ++ [ viewCreate model.create ]
```
 
Unsere updates werden aber nested.
Record update syntax ist nur für Variablen erlaubt ist, nicht für Zugriffe - wir müssten also erst ein let binding bauen:
```elm
...
    UpdateTitle title ->
            let 
                create = model.create
            in
            { model | create = { create | title = title } }
```
Besser: Updates von create auslagern:
```elm
updateCreate : CreateMsg -> TodoCreate -> TodoCreate
updateCreate msg create =
    case msg of
        UpdateTitle title ->
            { create | title = title }

        UpdateDesc desc ->
            { create | desc = desc }

update msg model =
      ...
        CreateMsg createMsg ->
            { model | create = updateCreate createMsg model.create }

        CreateTodo ->
            { model | todos = model.todos ++ [ Todo False model.create.title model.create.desc ] }
```

Erfahrung zeigt aber: nested models sind oft problematisch.
Oft ist folgendes Muster besser:
```elm
type alias TodoCreate r =
    { r
        | title : String
        , desc : String
    }


type alias Model =
    { todos : List Todo

    -- Create
    , title : String
    , desc : String
    }
```
`TodoCreate` ist ein alias für ein _extensible record_, d.h. die Typvariable `r` muss all diese Felder haben.
Damit können wir das model flach halten, aber trotzdem Typen begrenzen - viewCreate nimmt einfach ein `TodoCreate r`.
```elm
init = 
    ...
    ""
    ""


updateCreate : CreateMsg -> TodoCreate r -> TodoCreate r
updateCreate msg create =
    case msg of
        UpdateTitle title ->
            { create | title = title }

        UpdateDesc desc ->
            { create | desc = desc }


update msg model =
    ...
        CreateMsg createMsg ->
            updateCreate createMsg model

        CreateTodo ->
            { model | todos = model.todos ++ [ Todo False model.title model.desc ] }


viewCreate : TodoCreate r -> Html Msg


view model =
    ...
            ++ [ viewCreate model ]
```
Damit haben wir fast alles durch, was man mit Typvariablen machen kann. Eine Besonderheit:
Es gibt ein paar eingebaute Typklassen (genannt constrained type variables): `eq`, `comparable`, mit entsprechend überladenen `=`, `<`, und automatisch
generierten Instanzen.
 

Unsere Anwendung kommuniziert immer noch nicht mit der Außenwelt.
Die Todos würden wir aber gerne einem backend übergeben!
Dazu stellen wir erst mal von `Browser.sandbox` auf `Browser.element` um:
```elm
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model
        [ Todo True "Hello world" "Write hello world app"
        , Todo False "Todo" "Write todo app"
        ]
        ""
        ""
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ... ({model | ...}, Cmd.none)

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions =
    always Sub.none
```
Subscriptions sind dafür da, um unabhängig von unserer update loop (z.B. mit Timer) `Cmd`s auszulösen.

Bei Anwendungsstart wollen wir uns erst mal die Todos per GET bekommen.
Dazu installieren wir unser erst mal das http und das url package: `elm install elm/http elm/json`.
Dann löschen wir das `desc` Feld überall (kann das Backend nicht), und schreiben den Request:
```elm
import Http
import Url.Builder as UrlBuilder
import Json.Decode as Decode exposing (Decoder)

backend =
    "https://todo-backend-akka.herokuapp.com/todos"


todosDecoder : Decoder (List Todo)
todosDecoder =
    Decode.list <|
        Decode.map2 Todo
            (Decode.field "completed" Decode.bool)
            (Decode.field "title" Decode.string)


getTodos : Cmd Msg
getTodos =
    Http.get { url = backend, expect = Http.expectJson (Result.withDefault [] >> LoadedTodos) todosDecoder }


init _ = 
    (...
    , getTodos )


type Msg
     = ...
     | LoadedTodos (List Todo)

update msg model =
    ...
        LoadedTodos todos ->
            ( { model | todos = todos }, Cmd.none )
```
`Http.get` nimmt hier eine url und ein expect (json) - das kriegt den decoder für das json mit, und eine Anleitung,
was es mit dem Http result machen soll (Fehlschlag -> `[]` als default, dann in `LoadedTodos` message verpacken).
Der Decoder wird mit combinators zusammengebaut - einen String-Decoder selbst zu bauen ist zB in Usercode nicht möglich.

Zur Übersichtlichkeit lagern wir mal das ganze Todo-Zeugs in ein eigenes Modul aus (`src/Todo.elm`):
```elm
module Todo exposing
    ( Todo
    , decoder, list
    )

{-| Module for to do entries (http and stuff).


# Types

@docs Todo


# Http stuff

@docs decoder, list

-}

import Http
import Json.Decode as Decode exposing (Decoder)


type alias Todo =
    { done : Bool
    , title : String
    }


decoder : Decoder Todo
decoder =
    Decode.map2 Todo
        (Decode.field "completed" Decode.bool)
        (Decode.field "title" Decode.string)


list : String -> (List Todo -> msg) -> Cmd msg
list url toMsg =
    Http.get { url = url, expect = Http.expectJson (Result.withDefault [] >> toMsg) (Decode.list decoder) }
```

Jetzt wollen wir noch abgehakte todos löschen. 
Dazu müssen wir die urls der Todo entries speichern - das ist natürlich super nervig, weil wir das neue Feld dann überall
mitziehen müssen.
Deshalb kapseln wir den Typ gleich mal ab:
```elm
type Todo
    = Todo TodoItem


type alias TodoItem =
    { done : Bool
    , title : String
    , url : String
    }
```
Per default sind nämlich die Konstruktoren von `type Todo` nicht exportiert (`exposing Todo(..)`), d.h. niemand kann
von außen den Konstruktor aufrufen, sondern nur unserer create methode.

Erzeugen machen wir jetzt nicht mehr selber, sondern speichern auf dem Backend. `Todo.elm`:
```elm
module Todo exposing ..., create, view


import Json.Encode as Encode


decoder =
    ...
            (Decode.field "url" Decode.string)


create : String -> String -> msg -> Cmd msg
create url title msg =
    Http.post
        { url = url
        , body = Http.jsonBody <| Encode.object [ ( "title", Encode.string title ) ]
        , expect = Http.expectWhatever <| always msg
        }


viewTodo : (Todo -> msg) -> Todo -> Html msg
viewTodo toMsg (Todo todo) =
    let
        itemStyle =
            if todo.done then
                [ style "text-decoration" "line-through" ]

            else
                []
    in
    div []
        [ label itemStyle
            [ input
                [ type_ "checkbox"
                , checked todo.done
                , onClick <| toMsg <| Todo { todo | done = not todo.done }
                ]
                []
            , text <| todo.title
            ]
        ]
```
`Main.elm`:
```elm
type Msg 
    = ...
    | LoadTodos


update msg model =
    ...
    CreateTodo ->
        ( { model | create = "" }, Todo.create backend model.create LoadTodos )
    
    LoadTodos ->
        (model, Todo.list backend LoadedTodos)


view model =
    ...
        List.indexedMap (Todo.view << UpdateTodo) model.todos
            ...
```

Jetzt noch delete:
```elm
delete : String -> msg -> Todo -> Cmd msg
delete url msg (Todo todo) =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectWhatever (always msg)
        , timeout = Nothing
        , tracker = Nothing
        }
```
und
```elm
type Msg
    = DeleteTodo Int Todo
    ...

update msg model =
    case msg of
        DeleteTodo i todo ->
            ( { model | todos = List.take i model.todos ++ [ todo ] ++ List.drop (i + 1) model.todos }, Todo.delete LoadTodos todo )
```