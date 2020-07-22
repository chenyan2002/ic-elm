import R "mo:base/Result";
import A "mo:base/Array";
import I "mo:base/Iter";
import Prim "mo:prim";
import P "mo:base/Principal";

type Matrix = [[Int]];
type List<T> = ?{head: T; tail: List<T>};
type List2<T> = { #nil; #cons: (T, List2<T>) };
type Opt = ?Opt;
type Record = { name: Text; age: Nat8 };
type NestedRecord = { A: Record; B: ?NestedRecord; C: R.Result<List<Int>, Text> };

actor Self {
    public query func myId() : async Principal {
        P.fromActor(Self)
    };
    public query func isMyId(id: Principal) : async Bool {
        id == P.fromActor(Self)
    };

  public query func greet(name : Text) : async Text {
      return "Hello, " # name # "!";
  };
  
  public query func fib(n:Nat) : async Int {
      let f: [var Int] = A.init<Int>(2, 1);
      f[0] := 0;
      for (i in I.range(2, n)) {
          f[i%2] := f[(i-1)%2] + f[(i-2)%2];
      };
      return f[n%2];
  };
  
  public query { caller = c } func getCaller() : async (Principal, Word32) {
      return (c, Prim.hashBlob (Prim.blobOfPrincipal c));
  };
  
  public query func id_float(id: Float): async Float { id };

  public query func id_principal(id: Principal): async Principal {
      return id;
  };

  public func id_service(id: actor { greet: (Text) -> async Text }, name: Text): async Text {
      return await id.greet(name);
  };

  public query func id_opt(id: Opt): async Opt { id };
  public query func id_opt_list(id: List<Int8>): async List<Int8> { id };
  public query func id_variant_list(id: List2<Int8>): async List2<Int8> { id };
  public query func id_variant(id: R.Result<Text, Nat8>): async R.Result<Text, Nat8> { id };
  public query func id_nested(id: NestedRecord): async NestedRecord { id };
  public query func id_vec(id: [Record]): async [Record] { id };
  public query func id_tuple(id: (Nat, Int)): async (Nat, Int) { id };
  public query func id_matrix(id: Matrix): async Matrix { id };
  
  public func vec_map(f: shared (Text) -> async (Text), vec: [Text]): async [Text] {
      let n = vec.size();
      let arr = A.init<Text>(n, "");
      var i = 0;
      while (i < n) {
          arr[i] := await f(vec[i]);
          i += 1;
      };
      return A.freeze(arr);
  };
};
