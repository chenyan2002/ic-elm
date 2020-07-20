import elm from 'ic:canisters/elm';

elm.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
