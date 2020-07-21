port module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

port sendMessage : String -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg

type alias Model = { input : String, output : String }

init : () -> (Model, Cmd msg)
init _ = (Model "" "", Cmd.none)

type Msg = Send | Recv String | Changed String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Changed input -> ( { model | input = input }, Cmd.none)
    Send ->
        ( { model | output = "Waiting..." }
        , sendMessage model.input
        )
    Recv message ->
        ( { model | output = message }
        , Cmd.none
        )

subscriptions : Model -> Sub Msg
subscriptions _ = messageReceiver Recv

view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "text", onInput Changed, value model.input ] []
    , button [ onClick Send ] [ text "Call" ]
    , div [] [ text model.output ]
    ]
