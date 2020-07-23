import backend from 'ic:canisters/backend';
import { Elm } from './Main.elm';

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, args]) => {
  backend[method](...args)
    .then(res => {
      app.ports.messageReceiver.send([method, res]);
    })
    .catch(error => {
      app.ports.messageError.send([method, error.message]);
      throw error;
    });
});
