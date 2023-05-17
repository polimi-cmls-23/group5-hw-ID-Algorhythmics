NetAddr.localAddr
(
// retrieve the current IP and port
n = NetAddr.new("127.0.0.1", 57120);
// create the
// NetAddr
// create the OSCFunc
/*o = OSCFunc({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln;"sss".postln }, '/receive', n);*/
o = OSCFunc.newMatching({ "sss".postln }, '/message');
)
o.free;

(
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
OSCFunc.trace(false); 