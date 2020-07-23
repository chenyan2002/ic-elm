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
port messageReceiver : ((String, String) -> msg) -> Sub msg
port messageError : ((String, E.Value) -> msg) -> Sub msg

greet : String -> Cmd msg
greet name = sendMessage("greet", [E.string name])
greetDecoder : E.Value -> String
greetDecoder val = Result.withDefault "" (D.decodeValue D.string val)
fib : Int -> Cmd msg                   
fib n = sendMessage("fib", [E.int n])
fibDecoder : E.Value -> Int
fibDecoder val = Result.withDefault -1 (D.decodeValue D.int val)

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch [messageReceiver Recv, messageError Error]

type alias Model = { input : String, output : String }

init : () -> (Model, Cmd msg)
init _ = (Model "" "", Cmd.none)

type Msg = Send | Recv (String, String) | Changed String | Error (String, E.Value)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Changed input -> ( { model | input = input }, Cmd.none)
    Send ->
        ( { model | output = "Waiting..." }
        --, sendMessage ("getCaller", [])
        --, sendMessage ("fib", [E.int (Maybe.withDefault 0 (String.toInt model.input))])
        --, sendMessage ("greet", [E.string model.input])
        --, greet(model.input)
        , fib(Maybe.withDefault 0 (String.toInt model.input))
        )
    Recv (method, message) ->
        --let result = E.encode 0 message in 
        --let result = String.fromInt (fibDecoder message) in
        --let result = greetDecoder message in
        ( { model | output = method ++ ": " ++ message }
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
