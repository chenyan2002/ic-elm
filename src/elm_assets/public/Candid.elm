port module Candid exposing (..)

import Json.Encode as E
import Json.Decode as D
import BigInt exposing (BigInt)

port sendMessage : (String, List E.Value) -> Cmd msg
port messageReceiver : ((String, E.Value) -> msg) -> Sub msg
port messageError : ((String, E.Value) -> msg) -> Sub msg

type alias Principal = String

bigint : D.Decoder BigInt
bigint = D.string |> D.andThen bigintHelper
bigintHelper str =
    case BigInt.fromIntString str of
        Just num -> D.succeed num
        Nothing -> D.fail "not bigint"

encodeBigInt n = BigInt.toString n |> E.string

greet : String -> Cmd msg
greet name = sendMessage("greet", [E.string name])
fib : BigInt -> Cmd msg
fib n = sendMessage("fib", [encodeBigInt n])
getCaller () = sendMessage("getCaller", [])

type ReturnValue = Greet String | Fib BigInt | GetCaller (Principal, Int) | Error_ String

toString val =
    case val of
        Greet str -> str
        Fib int -> BigInt.toString int
        GetCaller (id, word) -> id ++ ", " ++ String.fromInt word
        Error_ err -> err

greetDecoder = D.index 0 D.string |> D.map Greet
fibDecoder = D.index 0 bigint |> D.map Fib
callerDecoder = D.map2 Tuple.pair (D.index 0 D.string) (D.index 1 D.int) |> D.map GetCaller
decode decoder msg =
    case D.decodeValue decoder msg of
        Ok v -> toString v
        Err err -> D.errorToString err
