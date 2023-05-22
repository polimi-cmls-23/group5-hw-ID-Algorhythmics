NetAddr.localAddr
(
// retrieve the current IP and port
~on.free;

n = NetAddr.new("127.0.0.1", 57120);
// define osc

~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	if( status == 'on',{a = Synth(\waveguideFlute,[\freq, freq]);},{a.free})
}, '/play/recorder');
)