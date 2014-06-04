var engine = require('engine.io');
var server = engine.listen(8000);

server.on('connection', function(socket){
  socket.send('hi');
  // Bounce any received messages back
  socket.on('message', function (data) {
    if (data === 'give binary') {
      var abv = new Int8Array(5);
      for (var i = 0; i < 5; i++) {
        abv[i] = i;
      }
      socket.send(abv);
      return;
    }
    console.log('got data %j', data);
    socket.send(data);
  });
});
