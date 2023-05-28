NetAddr.localAddr
(
// retrieve the current IP and port
~on.free;
~control.free;

n = NetAddr.new("127.0.0.1", 57120);
// define osc

~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	if( status == 'on',{a = Synth(\waveguideFlute,[\freq, freq]);},{a.free})
}, '/play/recorder');


~control = OSCFunc({ |msg, time, addr, recvPort|
	var operation = msg[1];
	var value = msg[2];
	if(operation=='upAmplitude'||operation=='downAmplitude',{
		~volumeSlider.value_(~volumeSlider.value+=value);
	});
	if(operation=='upAttack'||operation=='downAttack',{

	});
	if(operation=='upRelease'||operation=='downRelease',{

	});
	if(operation=='upFrequency'||operation=='downFrequency',{

	});
	if(operation=='upDepth'||operation=='downDepth',{

	});
	if(operation=='upMix'||operation=='downMix',{

	});
	if(operation=='upReverbTime'||operation=='downReverbTime',{

	});
	if(operation=='upPreDelay'||operation=='downPreDelay',{

	});
}, '/control');
)

