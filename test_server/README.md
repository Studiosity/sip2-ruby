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
