import backend from 'ic:canisters/backend';
import candid from 'ic:idl/backend';
import { IDL } from '@dfinity/agent';
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

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, args]) => {
  backend[method](...args)
    .then(res => {
      const func = service[method];
      const result = normalizeReturn(func.retTypes, res);
      const text = IDL.FuncClass.argsToString(func.retTypes, result);
      app.ports.messageReceiver.send([method, text]);
    })
    .catch(error => {
      app.ports.messageError.send([method, error.message]);
      throw error;
    });
});
