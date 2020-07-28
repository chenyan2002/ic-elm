port module Candid exposing (..)

import Json.Encode as E
import Json.Decode as D

port sendMessage : (String, List E.Value) -> Cmd msg
port messageReceiver : ((String, E.Value) -> msg) -> Sub msg
port messageError : ((String, E.Value) -> msg) -> Sub msg

type alias Principal = String

greet : String -> Cmd msg
greet name = sendMessage("greet", [E.string name])

greetDecoder : D.Decoder String
greetDecoder = D.index 0 D.string
