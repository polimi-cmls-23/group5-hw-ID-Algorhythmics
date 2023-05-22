NetAddr.localAddr
(
// retrieve the current IP and port
~on.free;

n = NetAddr.new("127.0.0.1", 57120);
// define osc

~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	if()
	msg[1].postln;
}, '/play/recorder');
)

/*(
m = NetAddr("127.0.0.1", 57121); // loopback
​
m.sendMsg("/message", "Hello App 1");
)

(
m = NetAddr("127.0.0.1", 57120); // loopback
​
m.sendMsg("/message", "Hello App 1");
)

OSCFunc.trace(true,hideStatusMsg: true);
OSCFunc.trace(false); */