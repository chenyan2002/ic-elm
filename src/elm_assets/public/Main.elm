port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E
import Json.Decode as D

main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

port sendMessage : (String, E.Value) -> Cmd msg
port messageReceiver : ((String, String) -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions _ = messageReceiver Recv

type alias Model = { input : String, output : String }

init : () -> (Model, Cmd msg)
init _ = (Model "" "", Cmd.none)

type Msg = Send | Recv (String, String) | Changed String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Changed input -> ( { model | input = input }, Cmd.none)
    Send ->
        ( { model | output = "Waiting..." }
        , sendMessage ("fib", E.int (Maybe.withDefault 0 (String.toInt model.input)))
        )
    Recv (method, message) ->
        ( { model | output = method ++ ": " ++ message }
        , Cmd.none
        )

view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "text", onInput Changed, value model.input ] []
    , button [ onClick Send ] [ text "Call" ]
    , div [] [ text model.output ]
    ]
