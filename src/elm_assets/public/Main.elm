module Main exposing (..)

import Browser
import Candid
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Encode as E

main =
  Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch [Candid.messageReceiver Recv, Candid.messageError Error]

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
        --, Candid.greet(model.input)
        , Candid.getCaller()
        --, Candid.fib(model.input)
        )
    Recv (method, message) ->
        --let result = E.encode 0 message in
        let result = Candid.decode Candid.callerDecoder message in
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
