const net = require("net");
const config = require("config");

calculateChecksum = (message)=> {
  let check = 0;
  for (let i = 0; i < message.length; i++ ) {
    check += message.charCodeAt(i);
  }
  return ((check ^ 0xFFFF) + 1).toString(16).toUpperCase();
}

const server = net.createServer((socket)=> {
  let authenticated = false;

  let buffer = "";
  socket.on("data", (data)=> {
    buffer += data;

    // Sanity check to deal with the unexpected
    if (buffer.length > 200) {
      buffer = "";
      return
    }

    let eol = buffer.indexOf('\r');
    while (~eol) {
      socket.emit("line", buffer.substring(0, eol));
      buffer = buffer.substring(eol + 1);
      eol = buffer.indexOf('\r');
    }
  });

  let sequenceNumber, match;

  socket.sendResponse = (message, excludeSequence)=> {
    if (config.server.errorDetectionEnabled) {
      if (!excludeSequence) {
        message += `AY${sequenceNumber}`;
      }
      message += 'AZ';
      message += calculateChecksum(message);
    }
    console.log(`Responding: ${message}`);
    socket.write(`${message}\r`);
  };

  socket.on("line", (line)=> {
    console.log(`Received: ${line}`);

    sequenceNumber = "";
    if (config.server.errorDetectionEnabled) {
      const errorDetectionRegex = /(.*AY([0-9])AZ)([0-9A-Z]{4})$/
      let message, checksum;
      [match, message, sequenceNumber, checksum] = line.match(errorDetectionRegex);

      // Now calculate the message checksum
      if (calculateChecksum(message) != checksum) {
        // Checksum error
        socket.sendResponse("96", true);
        return
      }
    }

    switch (line.substring(0, 2)) {
      case "93": // Login
        const loginRegex = /^93([0-9])([0-9])CN([^|]*)\|CO([^|]*)\|CP([^|]*)\|/
        let uidAlgorithm, pwdAlgorithm, loginUser, loginPassword, locationCode;
        [match, uidAlgorithm, pwdAlgorithm, loginUser, loginPassword, locationCode] = line.match(loginRegex);

        authenticated = config.login.user === loginUser && config.login.password === loginPassword;

        socket.sendResponse(`94${authenticated ? '1' : '0'}`);
        break;
    }
  });
});

server.listen(config.server.port, config.server.host, ()=> {
  console.log(`SIP2 test server started. Listening on ${config.server.host}:${config.server.port}`);
});
