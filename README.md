# ic-elm

A template for using Elm to develop frontend user interface for the Internet Computer.

# Overview

Elm --> JSON --> JS Candid Encoder --> IC canister --> JS Candid Decoder --> JSON --> Elm

Currently Candid methods is untyped to Elm. The error only happens on the JS side in the runtime.

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
