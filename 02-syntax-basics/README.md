# Syntax Basics
Schauen wir uns das mal im detail an. Rückwärts.
```elm
view : Model -> Html Msg
view model =
    text "Hello World"
```
Das definiert eine Funktion. Name 'view'.
1. Zeile: Gibt Typ an: Nimmt ein `Model`, gibt `Html Msg` zurück.
2. Zeile: Definition. Argumente vor dem `=`, d.h. `model` ist vom typ `Model`.
3. Zeile: Expression. `text` ist wieder eine Funktion - diesmal nimmt die ein String und gibt Html zurück.
Elm ist funktional, also ist jeder Body eine Expression.
String-Operation:
```elm
text ("Hello" ++ " " ++ "World")
```

Kommentare:
```elm
-- single line
{-
multiline
}-
{-| Doc comment.

-}
```

Nächster Block:
```elm
update : Msg -> Model -> Model
update msg model =
    model
```
Funktion mit mehreren Parametern. Nimmt `Msg`, dann `Model`, gibt ein `Model` zurück.
Wie in jeder anständigen funktionalen Sprache werden Argumente curried -
steckt ihr nur eine `Msg` rein, kriegt ihr eine Funktion `Model -> Model` zurück.
Die Funktion macht nicht viel, gibt nur das Model wieder zurück.

```elm
type Msg =
    Greeting String
```
Neue Tops-Level Konstrukt: Datentypen.
Das definiert einen neuen Typen `Msg`.
Typen (außer so build-ins wie String) haben immer zuerst einen Konstruktor (`Hi`),
dann kommen die Daten - in dem Fall ein String.
Typen sind prinzipiell tagged union types, d.h. wir können so was machen:
```elm
type Msg
    = Greeting String
    | SomethingElse Int Int
```
Wenn wir eine `Msg` erzeugen wollen, müssen wir immer den Konstruktor aufrufen:
```elm
example = Greeting "Hi!"
```

Weiter oben:
```elm
type alias Model =
    { field : String }


init : Model
init =
    { field = "value" }
```
Neben typen gibt es noch typ aliase - hier `Model` - damit geben einem Typ einen Namen.
Der eigentliche Typ ist aber der Record!
Weil wir Records fast immer Namen geben wollen (sonst ist die Signatur so lang),
verwenden wir aber eigentlich immer type aliases für Records.
Records types werden 'Feldname: Typ' geschrieben.
In der Zeile Drunter dann Instanziierung von einem Record: `=` statt `:`.
Eine besonderheit: Typ alias für Records erzeugt auch eine Konstruktor-Funktion,
in der wir Werte für die Felder der Reihe nach übergeben:
```elm
init =
    Model "value"
```

Dann etwas Boilerplate. Hier gibt es ein paar verschiedene Type, wir verwenden erstmal `sandbox`:
```elm
main =
    Browser.sandbox { init = init, update = update, view = view }
```
- `init`: erstes Model
- `update`: update-Funktion, noch ohne `cmd`
- `view`: render-Funktion

Ganz oben dann das super-simple Modulsystem. Am Anfang steht das Modul von unserem File,
exposed Sachen werden exportiert, `..` steht für Alle.
Imports funktionieren genauso.

Eine Sache haben wir übersprungen: `Html Msg`. `Html` nimmt einen Typ-parameter:
```elm
type alias Html msg = ...
```
Typ-parameter werden immer klein geschrieben.
 

Als Nächstes basteln wir mal ein Beispiel mit Interaktion - eine Todo-Liste.