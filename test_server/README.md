# Test SIP2 server
To help in testing this gem, this NodeJS based server will respond to SIP2
login requests. 

## Configuration
The configuration file is found in config/default.json

Options available include server host/port as well as the ACS username/password

Future expansion of the server would likely include implementation of the
patron information request/response 

## Setup
```bash
npm install
```

## Running the server
```bash
node index.js
```

This will start a demonstration SIP2 server on port 6000

## Supported messages

Current messages supported by the test server are:

* 93 - Login

## Running the stunnel server to test SSL connections
```bash
stunnel stunnel/stunnel.conf
```

The configuration is set to accept SSL connections on port 6001 and will proxy those
requests through to the node server running on port 6000
