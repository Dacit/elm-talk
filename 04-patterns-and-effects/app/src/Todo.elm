module Todo exposing
    ( Todo
    , create, list, delete
    , view
    )

{-| Module for to do entries (http and stuff).


# Types

@docs Todo


# Http stuff

@docs create, list, delete


# MVU

@docs view

-}

import Html exposing (Html, div, input, label, text)
import Html.Attributes exposing (checked, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Todo
    = Todo TodoItem


type alias TodoItem =
    { done : Bool
    , title : String
    , url : String
    }


decoder : Decoder TodoItem
decoder =
    Decode.map3 TodoItem
        (Decode.field "completed" Decode.bool)
        (Decode.field "title" Decode.string)
        (Decode.field "url" Decode.string)


listDecoder : Decoder (List Todo)
listDecoder =
    Decode.list <| Decode.map Todo decoder


create : String -> String -> msg -> Cmd msg
create url title msg =
    Http.post
        { url = url
        , body = Http.jsonBody <| Encode.object [ ( "title", Encode.string title ) ]
        , expect = Http.expectWhatever <| always msg
        }


list : String -> (List Todo -> msg) -> Cmd msg
list url toMsg =
    Http.get { url = url, expect = Http.expectJson (Result.withDefault [] >> toMsg) listDecoder }


view : (Todo -> msg) -> Todo -> Html msg
view toMsg (Todo todo) =
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


delete : msg -> Todo -> Cmd msg
delete msg (Todo todo) =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = todo.url
        , body = Http.emptyBody
        , expect = Http.expectWhatever (always msg)
        , timeout = Nothing
        , tracker = Nothing
        }
