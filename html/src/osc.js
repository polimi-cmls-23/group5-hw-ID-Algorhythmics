import osc from "osc/dist/osc-browser.min.js";
let oscPort = new osc.WebSocketPort({
    url: "ws://localhost:8081",
    metadata: true
});
function OSCInit(){
    oscPort.open();
    oscPort.on("ready", function () {
        console.log('OSC is ready')
        // oscPort.send({
        //     address: "/message",
        //     args: [
        //         {
        //             type: "f",
        //             value: 440
        //         }
        //     ]
        // });
    });
    return oscPort
}
export {OSCInit}

