import backend from 'ic:canisters/backend';
import { Elm } from './Main.elm';

const app = Elm.Main.init({
  node: document.getElementById('app'),
});

app.ports.sendMessage.subscribe(([method, message]) => {
  backend[method](message).then(res => {
    app.ports.messageReceiver.send([method, res]);
  });
});
