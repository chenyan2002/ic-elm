import BigNumber from 'bignumber.js';
import backend from 'ic:canisters/backend';
import candid from 'ic:idl/backend';
import { IDL, CanisterId } from '@dfinity/agent';
import { Elm } from './Main.elm';

const service = Object.assign(...candid({IDL})._fields.map(([key, val]) => ({[key]: val})));

function normalizeReturn(types, res) {
  let result;
  if (types.length === 0) {
    result = [];
  } else if (types.length === 1) {
    result = [res];
  } else {
    result = res;
  }
  return result;
}

class Candid2JSON extends IDL.Visitor {
  visitType(t, v) {
    return v;
  }
  visitNumber(t, v) {
    return v.toFixed();
  }
  visitFixedInt(t, v) {
    if (t._bits <= 32) {
      return v;
    } else {
      return v.toFixed();
    }
  }
  visitFixedNat(t, v) {
    if (t._bits <= 32) {
      return v;
    } else {
      return v.toFixed();
    }
  }
  visitPrincipal(t, v) {
    return v.toText();
  }
  visitService(t, v) {
    return v.toText();
  }
  visitFunc(t, v) {
    return [v[0].toText(), v[1]];
  }
  visitRec(t, ty, v) {
    return toJson(ty, v);
  }
}

class JSON2Candid extends IDL.Visitor {
  visitType(t, v) {
    return v;
  }
  visitNumber(t, v) {
    return new BigNumber(v);
  }
  visitPrincipal(t, v) {
    return canisterId.fromText(v);
  }
  visitService(t, v) {
    return canisterId.fromText(v);
  }
  visitFunc(t, v) {
    return [canisterId.fromText(v[0]), v[1]];
  }
  visitRec(t, ty, v) {
    return fromJson(ty, v);
  }  
}

function toJson(t, v) {
  return t.accept(new Candid2JSON(), v);
}

function fromJson(t, v) {
  return t.accept(new JSON2Candid(), v);
}

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, json_args]) => {
  const func = service[method];
  const args = func.argTypes.map((t, i) => fromJson(t, json_args[i]));
  backend[method](...args)
    .then(res => {
      const result = normalizeReturn(func.retTypes, res);
      const json = func.retTypes.map((t, i) => toJson(t, result[i]));
      app.ports.messageReceiver.send([method, json]);
    })
    .catch(error => {
      app.ports.messageError.send([method, error.message]);
      throw error;
    });
});
