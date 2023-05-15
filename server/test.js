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

// Listen for Web Socket requests.
let wss = new WebSocket.Server({
    server: server
});

// Listen for Web Socket connections.
wss.on("connection", function (socket) {
    let socketPort = new osc.WebSocketPort({
        socket: socket,
        metadata: true
    });

    socketPort.on("message", function (oscMsg) {
        console.log("An OSC Message was received!", oscMsg);
        // forward to super collider
        // socketPort.send({
        //     address: "/message",
        //     args: "hello from nodejs"
        // });
    });
});
