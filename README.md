# ic-elm

A template for using Elm to develop frontend user interface for the Internet Computer.

# Overview

Elm --> JSON --> JS Candid Encoder --> IC canister --> JS Candid Decoder --> JSON --> Elm

Currently Candid methods is untyped to Elm. The error only happens on the JS side in the runtime.
Eventually, we want to generate method bindings in Elm via the Candid compiler.

# Design choices

There are several options for the `port` function type in Elm:

* JSON value: It's the recommended way for Elm-JS interop. To transfer JS objects, mainly BigNumber and CanisterId, we need to convert objects/classes into a JSON representation, which can be done via the visitor pattern. The downside is that Elm needs to understand the JS specific representation of the Candid values. We can provide a codegen from candid file to hide the representation detail from the user.
* Variant type: JS doesn't have variant types, and Elm cannot transfer native variant types directly. So we need to design a JSON encoding for variant types, which requires work in both JS and Elm.
* String (Candid text format): This is language agnostic, and we can build a library for parsing and stringify the Candid values completely in Elm. On the JS side, there is little work required. Conceptually, this is better than JSON, as the format is in the spec and language agnostic, but it requires more work in Elm.
* Blob (Candid binary format): Also language agnostic, but a bit heavy weight (building type tables, skipping unused fields, etc), and we don't get any code reuse from the JS library.

Overall, it seems the easiest approach is to use JSON for Elm-JS interop.

# Usage 

```bash
cd ic-elm
npm install
dfx canister create --all
dfx build
dfx canister install --all
```

To learn more before you start working with elm, see the following documentation available online:

- [Quick Start](https://sdk.dfinity.org/docs/quickstart/quickstart.html)
- [SDK Developer Tools](https://sdk.dfinity.org/docs/developers-guide/sdk-guide.html)
- [Motoko Programming Language Guide](https://sdk.dfinity.org/docs/language-guide/motoko.html)
- [Motoko Language Quick Reference](https://sdk.dfinity.org/docs/language-guide/language-manual.html)
