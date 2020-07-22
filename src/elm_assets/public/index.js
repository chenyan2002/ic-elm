import backend from 'ic:canisters/backend';
import candid from 'ic:idl/backend';
import { IDL } from '@dfinity/agent';
import { Elm } from './Main.elm';

const arr = candid({IDL})._fields;
const service = Object.assign(...arr.map(([key, val]) => ({[key]: val})));

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, message]) => {
  backend[method](message).then(res => {
    const func = service[method];
    var result;
    if (func.retTypes.length === 0) {
      result = [];
    } else if (func.retTypes.length === 1) {
      result = [res];
    } else {
      result = res;
    }
    app.ports.messageReceiver.send([method, IDL.FuncClass.argsToString(func.retTypes, result)]);
  });
});
