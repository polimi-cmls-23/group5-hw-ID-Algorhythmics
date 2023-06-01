(

Window.closeAll;

Server.killAll;

s.waitForBoot({
// retrieve the current IP and port
~on.free;
~control.free;

n = NetAddr.new("127.0.0.1", 57120);

// default params for OSC control
~control_volume = 0.5;
~control_att = 0.1;
~control_release = 0.2;
~control_vibFre = 5;
~control_vibDep = 30;
// define osc
~synthDict = ();
~on = OSCFunc({ |msg, time, addr, recvPort|
	var status = msg[1];
	var freq = msg[2];
	var name = msg[3];
		// name.postln;
	if( status == 'on',{
		var synth = Synth.new(\waveguideFlute,[
			\freq, freq,
			\atk, ~control_att,
			\rel, ~control_release,
			\vdep, ~control_vibDep / 100,
			\vfr, ~control_vibFre,
			\amp, ~control_volume,
			\out, ~reverbSynth
		]);
		~synthDict.put(name, synth);
	},{
		var synth = ~synthDict.at(name);
		synth.free;
		~synthDict.removeAt(name);
		// freq.postln;

	})
}, '/play/recorder');

~demo = OSCFunc({ |msg, time, addr, recvPort|
		Pdef(\demo, Pbind(
			\instrument, \waveguideFlute,
			// \dur, 4,
			\dur, Pseq([Pn(Pseq([ 3,3,3, 2,  2, 1, 2, 4/3,4/3,4/3, 2,  1,  2,  2,  1,  1,  3]), 2)]/6.5),
			\midinote, Pseq([Pn(Pseq([62, 57, 54, 59, 61, 60, 59, 57, 66, 69, 71, 67, 69, 66, 62, 64, 61]), 2)])
		)).play;
}, '/play/demo');

~control = OSCFunc({ |msg, time, addr, recvPort|
	var operation = msg[1];
	var value = msg[2];
		// operation.postln;

	defer {
	if((operation=='upAmplitude')||(operation=='downAmplitude'),{
		var temp = ~volumeSlider.value+value;
		~volumeSlider.value_(temp);
		~control_volume = temp;
	});
	if((operation=='upAttack')||(operation=='downAttack'),{
		var temp = ~attAmpBox.value+value;
		~attAmpKnob.valueAction_(temp.explin(0.001, 10, 0, 1));
		~attAmpBox.value_(temp);
		~control_att = temp;
	});
	if((operation=='upRelease')||(operation=='downRelease'),{
		var temp = ~relAmpBox.value+value;
		~relAmpKnob.valueAction_(temp.linlin(0.001, 10, 0, 1));
		~relAmpBox.value_(temp);
		~control_release = temp;
	});
	if((operation=='upFrequency')||(operation=='downFrequency'),{
		var temp = ~vibFreBox.value+value;
		~vibFreKnob.valueAction_(temp.linlin(0.1, 6, 0, 1));
		~vibFreBox.value_(temp);
		~control_vibFre = temp;
	});
	if((operation=='upDepth')||(operation=='downDepth'),{
		var temp = ~vibDepBox.value+value;
		~vibDepKnob.valueAction_(temp.linlin(0, 100, 0, 1));
		~vibDepBox.value_(temp);
		~control_vibDep = temp;
	});
	if((operation=='upMix')||(operation=='downMix'),{
		var temp = ~revMixBox.value+value;
		~revMixKnob.valueAction_(temp.linlin(0, 100, 0, 1));
		~revMixBox.value_(temp);
	});
	if((operation=='upReverbTime')||(operation=='downReverbTime'),{
		var temp = ~revTimeBox.value+value;
		~revTimeKnob.valueAction_(temp.linlin(0.001, 10, 0, 1));
		~revTimeBox.value_(temp);
	});
	if((operation=='upPreDelay')||(operation=='downPreDelay'),{
		var temp = ~revPreBox.value+value;
		~revPreKnob.valueAction_(temp.linlin(0.001, 3, 0, 1));
		~revPreBox.value_(temp);
	});
	};
	~synthDict.keysValuesDo.do {
			|key, value|
			key.set(
			\atk,~control_att,
			\rel, ~control_release,
			\vdep,~control_vibDep,
			\vfr,~control_vibFre,
			\amp,~control_volume,
			);

	};

}, '/control');


SynthDef("waveguideFlute", {
	arg scl = 0.2, freq = 440, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 20000, gate = 1, amp = 1, out = 0, atk = 0.1, rel = 0.2, vdep = 0.3, vfr = 5;
	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;
	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;
	ifqc = freq;
	kenv1 = EnvGen.kr(Env.new([ 0.0, 1.1 * ipress, ipress, ipress, 0.0 ], [ 0.06, 0.2, dur - 0.46, 0.2 ], 'linear' ), gate);
	kenv2 = EnvGen.kr(Env.new([ 0.0, 1.0, 1.0, 0.0 ], [ atk, dur - 0.02, rel ], 'linear' ), gate, doneAction: 2);
	kenvibr = EnvGen.kr(Env.new( [ 0.0, 0.0, 0.3, 0.3, 0.0 ], [ 0.5, 0.5, dur - 1.5, 0.5 ], 'linear'), gate);
	aflow1 = LFClipNoise.ar( sr, kenv1 );
	kvibr = SinOsc.ar( vfr, 0, 0.1 * kenvibr );
	asum1 = ( ibreath * aflow1 ) + kenv1 + kvibr;
	afqc = ifqc.reciprocal - ( asum1/20000 ) - ( 9/sr ) + ( ifqc/12000000 ) - block;
	fdbckArray = LocalIn.ar( 1 );
	aflute1 = fdbckArray;
	asum2 = asum1 + ( aflute1 * ifeedbk1 );
	ax = DelayC.ar( asum2, ifqc.reciprocal - block * 0.5, afqc * 0.5 - ( asum1/ifqc/cr ) + 0.001 );
	apoly = ax - ( ax.cubed );
	asum3 = apoly + ( aflute1 * ifeedbk2 );
	avalue = LPF.ar( asum3, 2000 );
	aflute1 = DelayC.ar( avalue, ifqc.reciprocal - block, afqc );
	fdbckArray = [ aflute1 ];
	LocalOut.ar( fdbckArray );
	signalOut = avalue;
	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ]*amp );
}).add;

// reverb synthDef

SynthDef(\reverb, {
	arg in, preDelay = 0.1, revTime = 0.3, revCut = 4500, revMix = 0.6, amp = 1, out = 0;
	var dry, wet, temp, sig, env;
	dry = In.ar(in, 2);
	temp = In.ar(in, 2);
	wet = 0;
	temp = DelayN.ar(temp, 0, 2, preDelay);
	16.do{
		temp = AllpassN.ar(temp, 0.03, {Rand(0.001, 0.05)}!2, revTime);
		temp = LPF.ar(temp, revCut);
		wet = wet + temp;
	};
	sig = XFade2.ar(dry, wet, 0.02 * revMix - 1, amp);
	Out.ar(out, sig);
}).add;

// audio bus setup

~audioBus = Bus.audio(s, 2);

// reverb setup
~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth.new(\reverb, [\in, ~reverbBus]).register;

// creates the window for the GUI

w = Window("YASC", Rect(
	( Window.screenBounds.width - 85 ) / 2,
	( Window.screenBounds.height - 510 ) / 2,
	550,
	190));
w.front.alwaysOnTop_(true).asView.fixedSize_(Size.new(500, 510));
w.onClose_({
		if(~reverbSynth.isPlaying) {
			~reverbSynth.free;
		};
});
v = UserView(w, Rect(0, 0, 800, 510));
i = Image.open(thisProcess.nowExecutingPath.dirname +/+ "img/background.jpg");
v.backgroundImage_(i);

// creates a composite view

~fluteLabel = StaticText(w, Rect(90, 20, 290, 60)).string_("YASC").align_(\center).stringColor_(Color.white).font_(Font("Monaco",50));

b = CompositeView(w, Rect(30, 110, 410, 365));
v.drawFunc = {
	Pen.strokeColor_(Color.fromHexString("#E6E7F2").alpha_(0.5));
	Pen.width_(3);
	Pen.strokeRect(Rect(30, 110, 435, 365));
	Pen.fillStroke;
};
~envLabel = StaticText(b, Rect(20, 25, 260, 20)).string_("AMPLITUDE ENVELOPE").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the knob, the numerical box and the label for amplitude envelope attack

~attAmpKnob = Knob(b, Rect(20, 65, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attAmpKnob.action_({
	arg obj;
	var atk = obj.value.linexp(0, 1, 0.001, 10);
	~control_att = obj.value;
	~attAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
});

~attAmpBox = NumberBox(b, Rect(55, 65, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attAmpBox.action_({
	arg obj;
	~control_att = obj.value;
	~attAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attAmpLabel = StaticText(b, Rect(55, 45, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for amplitude envelope release

~relAmpKnob = Knob(b, Rect(155, 65, 30, 30)).value_(0.2.explin(0.001, 10, 0, 1));
~relAmpKnob.action_({
	arg obj;
	var rel = obj.value.linexp(0, 1, 0.001, 10);
	~control_release = obj.value.linexp(0, 1, 0.001, 10);
	~relAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
});

~relAmpBox = NumberBox(b, Rect(190, 65, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.2);
~relAmpBox.action_({
	arg obj;
	~control_release = obj.value;
	~relAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~relAmpLabel = StaticText(b, Rect(190, 45, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates a composite view for the vibrato depth control and the relative label
~envLabel = StaticText(b, Rect(20, 140, 260, 30)).string_("VIBRATO CONTROLS").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the knob, the numerical box and the label for vibrato frequency

~vibFreKnob = Knob(b, Rect(20, 185, 30, 30)).value_(5.linlin(0.1, 6, 0, 1));
~vibFreKnob.action_({
	arg obj;
	var vfr = obj.value.linlin(0, 1, 0.1, 6);
	~control_vibFre = obj.value.linlin(0, 1, 0.1, 6);
	~vibFreBox.value_(obj.value.linlin(0, 1, 0.1, 6));
});

~vibFreBox = NumberBox(b, Rect(55, 185, 80, 30)).clipLo_(0.1).clipHi_(6).decimals_(1).value_(5);
~vibFreBox.action_({
	arg obj;
	~control_vibFre = obj.value;
	~vibFreKnob.valueAction_(obj.value.linlin(0.1, 6, 0, 1));
});

~vibFreLabel = StaticText(b, Rect(55,165 , 80, 20)).string_("Frequency (Hz)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for vibrato depth

~vibDepKnob = Knob(b, Rect(155, 185, 30, 30)).value_(30.linlin(0, 100, 0, 1));
~vibDepKnob.action_({
	arg obj;
	var vdep = obj.value.linlin(0, 1, 0, 100);
	~control_vibDep = obj.value.linlin(0, 1, 0, 100);
	~vibDepBox.value_(obj.value.linlin(0, 1, 0, 100));
});

~vibDepBox = NumberBox(b, Rect(190, 185, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(30);
~vibDepBox.action_({
	arg obj;
	~control_vibDep = obj.value;
	~vibDepKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~vibDepLabel = StaticText(b, Rect(190, 165, 80, 20)).string_("Depth (%)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates a composite view for the reverb controls

~revLabel = StaticText(b, Rect(20, 265, 410, 20)).string_("REVERB CONTROLS").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the knob, the numerical box and the label for reverb mix

~revMixKnob = Knob(b, Rect(20, 305, 30, 30)).value_(60.linlin(0, 100, 0, 1));
~revMixKnob.action_({
	arg obj;
	var revMix = obj.value.linlin(0, 1, 0, 100);
	~revMixBox.value_(obj.value.linlin(0, 1, 0, 100));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revMix, revMix);
	};
});
//todo
~revMixBox = NumberBox(b, Rect(55, 305, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(60);
~revMixBox.action_({
	arg obj;
	~revMixKnob.valueAction_(obj.value.linlin(0, 100, 0, 1));
});

~revMixLabel = StaticText(b, Rect(55, 285, 80, 20)).string_("Mix D/W (%)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for reverb time

~revTimeKnob = Knob(b, Rect(155, 305, 30, 30)).value_(0.3.explin(0.001, 10, 0, 1));
~revTimeKnob.action_({
	arg obj;
	var revTime = obj.value.linexp(0, 1, 0.001, 10);
	~revTimeBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\revTime, revTime);
	};
});

~revTimeBox = NumberBox(b, Rect(190, 305, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.3);
~revTimeBox.action_({
	arg obj;
	~revTimeKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~revTimeLabel = StaticText(b, Rect(190, 285, 80, 20)).string_("Time (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for reverb pre-delay

~revPreKnob = Knob(b, Rect(280, 305, 30, 30)).value_(0.1.explin(0.001, 3, 0, 1));
~revPreKnob.action_({
	arg obj;
	var preDelay = obj.value.linexp(0, 1, 0.001, 3);
	~revPreBox.value_(obj.value.linexp(0, 1, 0.001, 3));
	if(~reverbSynth.isPlaying){
		~reverbSynth.set(\preDelay, preDelay);
	};
});

~revPreBox = NumberBox(b, Rect(315, 305, 80, 30)).clipLo_(0).clipHi_(3).decimals_(3).value_(0.1);
~revPreBox.action_({
	arg obj;
	~revPreKnob.valueAction_(obj.value.explin(0.001, 3, 0, 1));
});

~revPreLabel = StaticText(b, Rect(315, 285, 80, 20)).string_("Pre-Delay (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// VOLUME

~volumeLabel= StaticText(b, Rect(335, 230, 290, 23)).string_("VOLUME").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

~volumeSlider = Slider.new(b, Rect(315, 25, 30, 200)).orientation_(\vertical).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5)).value_(0.5);

ServerMeterView.new(s, b, 350@10, 0, 2);

~volumeSlider.action_({
	arg obj;
	~control_volume= obj.value;
});
})

)