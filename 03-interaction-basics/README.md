# Interaction Basics
Mit unserer Hello World Template bauen wir eine kleine App zum Anlegen von TODOs.
Neues Model:
```elm
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
```

Init (mit ein paar Einträgen):
```elm
init =
    Model
        [ Todo True "Hello world" "Write hello world app"
        , Todo False "Todo" "Write todo app"
        ]
        ""
        ""
```

Damit können wir auch gleich loslegen und uns um die Darstellung kümmern:
```elm
viewTodo : Todo -> Html Msg
viewTodo todo =
    div []
        [ label []
            [ input [ type_ "checkbox" ] []
            , text (todo.title ++ ": " ++ todo.desc)
            ]
        ]


view model =
    div [] (List.map viewTodo model.todos)
```
`div`, `label`, `input`... sind Funktionen aus dem `Html` Package (dieses, und `Html.Attributes` mit `..` importieren),
die das entsprechende Html erzeugen.
Als Argumente nehmen sie erst eine Liste von Attributen, dann eine Liste von Children. 

Statt die Expressions zu klammern, wie in `f (a + b)`, können wir 'Trenn-pipes' verwenden (`<|` und `|>`):
```elm
...
    div [] <| List.map viewTodo model.todos
```

Unsere Checkbox lässt sich jetzt zwar klicken, ist aber noch nicht mit der App verbunden - das machen wir als Nächstes.
Erst mal anzeigen:
```elm
viewTodo todo =
    let
        itemStyle =
            if todo.done then
                [ style "text-decoration" "line-through" ]

            else
                []
    in
    div itemStyle
        [ label foo
            [ input [ type_ "checkbox", checked todo.done ] []
    ...
```
`let ... = ... in ... ` ist einfach nur ein title binding.
`style` nimmt zwei argumente, die es als CSS key-value pair interpretiert.

```elm
type Msg
    = UpdateTodo Int Todo


update (UpdateTodo i todo) model =
    { model | todos = List.take i model.todos ++ [ todo ] ++ List.drop (i + 1) model.todos }
```
In der update-Funktion betreiben wir pattern matching auf das erste Argument, um an die Daten zu kommen.
Außerdem verwendet es den record update syntax, um nur das `todos` feld upzudaten.

Das update-event müssen wir noch erzeugen:
```elm
viewTodo : (Todo -> Msg) -> Todo -> Html Msg
viewTodo toMsg todo =
    div []
        [ label []
            [ input [ type_ "checkbox", onClick <| toMsg { todo | done = not todo.done } ] []
            , text <| todo.title ++ ": " ++ todo.desc
            ]
        ]


view model =
    div [] <| List.indexedMap (\i todo -> viewTodo (\newTodo -> UpdateTodo i newTodo) todo) model.todos
```
(`onClick` aus `Html.Events`)
Statt index übergeben wir der `viewTodo` direkt eine `toMsg`-Funktion.
`view` verwendet hier eine anonyme Funktion. Nach dem `\` stehen die Argmente, nach dem `->` dann der body.
Das ganze lässt sich natürlich viel kompakter schreiben:
```elm
(\i todo -> viewTodo (\newTodo -> UpdateTodo i newTodo) todo)
```
```elm
(\i -> viewTodo (UpdateTodo i))
```
```elm
(viewTodo >> UpdateTodo)
```
Wir bei `|>`, gibt es auch hier die andere Richtung `<<`. Insgesamt also:
```elm
view model =
    div [] <| List.indexedMap (viewTodo << UpdateTodo) model.todos
```

Jetzt müssen wir nur noch todos anlegen können:
```elm
view model =
    div [] <|
        List.indexedMap (viewTodo << UpdateTodo) model.todos
            ++ [ div []
                    [ input [ type_ "text", placeholder "title", value model.createTitle ] []
                    , input [ type_ "text", placeholder "description", value model.createTitle ] []
                    , button [] [ text "+" ]
                    ]
               ]
```
Vorsicht, Textfelder können implizit State halten, solange sie nicht verknüpft sind.
Sobald das Textfeld im rerender ausgetauscht wird, ist der aber weg!

Also fertig verknüpfen:
```elm
type Msg
    = UpdateTodo Int Todo
    | UpdateTitle String
    | UpdateDesc String
    | CreateTodo


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


inputField hint val onInp =
    input
        [ type_ "text"
        , placeholder hint
        , value val
        , onInput onInp
        ]
        []


view model = 
    ...
                    [ inputField "title" model.createTitle UpdateTitle
                    , inputField "description" model.createDesc UpdateDesc
                    , button [ onClick CreateTodo ] [ text "+" ]
                    ]
```
Die verschiedenen Messages unterscheiden wir per case distinction.


Ein `onEnter` gibt es nicht in der Standard-Library.
Um nicht mit keycodes zu hantieren, können wir noch `elm-extra` hinzufügen: `elm install elm-community/html-extra`,
und das `CreateTodo` event als `onEnter` (aus: `Html.Events.Extra exposing (onEnter)`) bei den inputFields hinzufügen.
 