port module Candid exposing (..)

import Json.Encode as E
import Json.Decode as D

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
