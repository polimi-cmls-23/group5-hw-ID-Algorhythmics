let osc = require("osc"),
    http = require("http"),
    WebSocket = require("ws");

// Create an Express server app
// and serve up a directory of static files.
let express = require("express");
let app = express()
app.get('/', function (req, res) {
    res.send('Hello World')
})
let server = app.listen(8081);

// app.use("/", express.static(__dirname + "/static"));

let wss = new WebSocket.Server({
    server: server
});

let udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121,
    remotePort:57120,
    remoteAddress:'127.0.0.1',
    // metadata: true
});
let udpPortReady = false;
udpPort.open();
// Listen
const recorder = 'recorder'
wss.on("connection", function (socket) {
    console.log("A Web Socket connection has been established!");
    // after get the message => send to SC
    let socketPort = new osc.WebSocketPort({
        socket: socket,
        metadata: true
    });

    socketPort.on("message", function (oscMsg) {
        // send to SC
        console.log("received");
        let str = oscMsg.args[0].value;
        // console.log("ss", JSON.parse(str).frequency);
        let obj = JSON.parse(str)
        let instrument = obj.instrument
        let address = '/play'
        if(instrument===recorder){
            address+=`/${recorder}`
        }
        console.log('address send',address)
        udpPort.send({
            address: address,
            args: [{
                type:'s',
                value:obj.status
            },{
                type:'f',
                value:obj.frequency
            }]
        });
    });
});
