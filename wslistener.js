const WebSocket = require('ws');

connectSocket();

function connectSocket() {
  const socket = new WebSocket('wss://api.roobet.party/socket.io/?EIO=3&transport=websocket'); // Replace with your server's URL

    socket.addEventListener('open', function(event) {
      console.log('Connected to the WebSocket server.');  
    });
    
    socket.addEventListener('message', function(event) {
      if (event.data.startsWith(42)) {
        const message = JSON.parse(event.data.substring(2));
        if (message[0] === "new_bet") {
          const {_id, betAmount,betId,gameName, payoutValue} = message[1];
          console.log(_id, betAmount,betId,gameName, payoutValue)
        }
      }
    });
    
    socket.addEventListener('close', function(event) {
      console.log('Disconnected from the WebSocket server.');
    });
    
    setInterval(() => {
      socket.send(2);
    }, 25000);
}