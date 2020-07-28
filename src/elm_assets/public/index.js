import backend from 'ic:canisters/backend';
import { Actor } from '@dfinity/agent';
import * as Util from './candidUtils';
import { Elm } from './Main.elm';

const service = Object.assign(...Actor.interfaceOf(backend)._fields.map(([key, val]) => ({[key]: val})));

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, json_args]) => {
  const func = service[method];
  const args = func.argTypes.map((t, i) => Util.fromJSON(t, json_args[i]));
  backend[method](...args)
    .then(res => {
      const result = Util.normalizeReturn(func.retTypes, res);
      const json = func.retTypes.map((t, i) => Util.toJSON(t, result[i]));
      app.ports.messageReceiver.send([method, json]);
    })
    .catch(error => {
      app.ports.messageError.send([method, error.message]);
      throw error;
    });
});
