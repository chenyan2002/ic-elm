import backend from 'ic:canisters/backend';
import candid from 'ic:idl/backend';
import { IDL } from '@dfinity/agent';
import { Elm } from './Main.elm';

const service = Object.assign(...candid({IDL})._fields.map(([key, val]) => ({[key]: val})));

function normalizeReturn(method, res) {
  const func = service[method];
  let result;
  if (func.retTypes.length === 0) {
    result = [];
  } else if (func.retTypes.length === 1) {
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
  backend[method](...args).then(res => {
    const result = normalizeReturn(method, res);
    app.ports.messageReceiver.send([method, result]);
  });
});
