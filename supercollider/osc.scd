NetAddr.localAddr
(
// retrieve the current IP and port
~on.free;
~control.free;

n = NetAddr.new("127.0.0.1", 57120);
// define osc
~synthDict = ();
~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	// ~volumeSlider.value.postln;
	if( status == 'on',{
		var synth = Synth(\waveguideFlute,[
			\freq, freq,
			\atk,~control_att,
			\rel, ~control_release,
			\vdep,~control_vibDep,
			\vfr,~control_vibFre,
		]);
		~synthDict.put(freq, synth);
	},{
		var synth = ~synthDict.at(freq);
		synth.free;
		~synthDict.removeAt(freq);
		// freq.postln;

	})
}, '/play/recorder');


~control = OSCFunc({ |msg, time, addr, recvPort|
	var operation = msg[1];
	var value = msg[2];
	if(operation=='upAmplitude'||operation=='downAmplitude',{
		~volumeSlider.value_(~volumeSlider.value+=value);
	});
	if(operation=='upAttack'||operation=='downAttack',{
		~attAmpBox.value_(~attAmpBox.value+=value)
	});
	if(operation=='upRelease'||operation=='downRelease',{
		~relAmpBox.value_(~relAmpBox.value+=value)
	});
	if(operation=='upFrequency'||operation=='downFrequency',{
		~vibFreBox.value_(~vibFreBox.value+=value)

	});
	if(operation=='upDepth'||operation=='downDepth',{
		~vibDepBox.value_(~vibDepBox.value+=value)
	});
	if(operation=='upMix'||operation=='downMix',{
		~revMixBox.value_(~revMixBox.value+=value)
	});
	if(operation=='upReverbTime'||operation=='downReverbTime',{
		~revTimeBox.value_(~revTimeBox.value+=value)
	});
	if(operation=='upPreDelay'||operation=='downPreDelay',{
		~revPreBox.value_(~revPreBox.value+=value)
	});
}, '/control');
)
// for debug
/*OSCFunc.trace(false);
s.dumpOSC(0);*/