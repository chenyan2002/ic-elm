port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E
import Json.Decode as D

main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

port sendMessage : (String, List E.Value) -> Cmd msg
port messageReceiver : ((String, E.Value) -> msg) -> Sub msg
port messageError : ((String, E.Value) -> msg) -> Sub msg

greet : String -> Cmd msg
greet name = sendMessage("greet", [E.string name])
fib : String -> Cmd msg
fib n = sendMessage("fib", [E.string n])
getCaller () = sendMessage("getCaller", [])

greetDecoder = D.index 0 D.string
fibDecoder = D.index 0 D.string
callerDecoder = D.map2 Tuple.pair (D.index 0 D.string) (D.index 1 D.int)
decode decoder msg =
    case D.decodeValue decoder msg of
        --Ok (id, word) -> "(" ++ id ++ ", " ++ String.fromInt word ++ ")"
        Ok str -> str
        Err err -> D.errorToString err

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch [messageReceiver Recv, messageError Error]

type alias Model = { input : String, output : String }

init : () -> (Model, Cmd msg)
init _ = (Model "" "", Cmd.none)

type Msg = Send | Recv (String, E.Value) | Changed String | Error (String, E.Value)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Changed input -> ( { model | input = input }, Cmd.none)
    Send ->
        ( { model | output = "Waiting..." }
        --, greet(model.input)
        --, getCaller()
        , fib(model.input)
        )
    Recv (method, message) ->
        --let result = E.encode 0 message in
        let result = decode fibDecoder message in
        ( { model | output = method ++ ": " ++ result }
        , Cmd.none
        )
    Error (method, message) ->
        let error = E.encode 0 message in
        ( { model | output = method ++ ": " ++ error }
        , Cmd.none
        )

view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "text", onInput Changed, value model.input ] []
    , button [ onClick Send ] [ text "Call" ]
    , div [] [ text model.output ]
    ]
