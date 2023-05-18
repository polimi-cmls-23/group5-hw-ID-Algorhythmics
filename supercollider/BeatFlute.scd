// Basic drum kit
(
SynthDef("hihat",
	{arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: PinkNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(sum, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

)

// flute synth

(

SynthDef("waveguideFlute", {
	arg scl = 0.2, freq = 440, bend = 0, ipress = 0.9, ibreath = 0.09, ifeedbk1 = 0.4, ifeedbk2 = 0.4, dur = 20000, gate = 1, amp = 2, out = 0, atk = 0.1, rel = 0.2, vdep = 0.3, vfr = 5;
	var kenv1, kenv2, kenvibr, kvibr, sr, cr, block;
	var poly, signalOut, ifqc;
	var aflow1, asum1, asum2, afqc, atemp1, ax, apoly, asum3, avalue, atemp2, aflute1;
	var fdbckArray;
	sr = SampleRate.ir;
	cr = ControlRate.ir;
	block = cr.reciprocal;
	ifqc = freq * bend.midiratio;
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
	OffsetOut.ar(out, [ signalOut * kenv2, signalOut * kenv2 ] );
}).add;

)

// reverb synth

(

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


)

// reverb synth and bus creation

~reverbBus = Bus.audio(s, 2);
~reverbSynth = Synth.new(\reverb, [\in, ~reverbBus]);
~reverbSynth.register;

// MIDI polyphonic synthesizer

(

MIDIClient.init;
MIDIIn.connectAll;

~liftednotes = Array.newClear(128);
~bend = 8192;

MIDIdef.noteOn(\noteOn, {
	arg velocity, noteNumber, channel, source;
	~notes[noteNumber] = Synth.new(
		"waveguideFlute",
		[   \freq, noteNumber.midicps,
			\amp, 2 * velocity.linexp(1, 127, 0.01, 0.3),
			\atk, ~attAmpKnob.value.linexp(0, 1, 0.001, 10),
			\rel, ~relAmpKnob.value.linexp(0, 1, 0.001, 10),
			\vfr, ~vibFreKnob.value.linlin(0, 1, 0.1, 6),
			\vdep, ~vibDepKnob.value.linlin(0, 1, 0, 100),
			\gate, 1,
			\bend, ~bend.linlin(0, 16383, -1, 1),
			\out, ~reverbBus
		]);
	~notes[noteNumber].register;
});

MIDIdef.noteOff(\noteOff, {
	arg velocity, noteNumber, channel, source;
	~notes[noteNumber].set(\gate, 0);
	~notes[noteNumber] = nil;
		});

MIDIdef.bend(\bendWheel, {
	arg value, channel, source;
	~bend = value;
	~notes.do{
		arg synth;
		synth.set(\bend, value.linlin(0, 16383, -1, 1))};
	}, chan: 0);

)

s.boot;

// GUI
(
~audioBus = Bus.audio(s, 2);


Window.closeAll;

// creates the window for the GUI

w = Window("BeatFlute", Rect(
	( Window.screenBounds.width - 85 ) / 2,
	( Window.screenBounds.height - 510 ) / 2,
	550,
	190));
w.front.alwaysOnTop_(true).asView.fixedSize_(Size.new(800, 510));
w.onClose_({
	s.freeAll;
});
v = UserView(w, Rect(0, 0, 800, 510));
i = Image.open(thisProcess.nowExecutingPath.dirname +/+ "img/sfondo.jpg");
v.backgroundImage_(i);

/*y = UserView(w, Rect(25, 5, 400, 250));
i = Image.open(thisProcess.nowExecutingPath.dirname +/+ "img/logo.png");
y.backgroundImage_(i);*/



// creates a composite view

~fluteLabel = StaticText(w, Rect(250, 20, 290, 60)).string_("YASC").align_(\center).stringColor_(Color.white).font_(Font("Monaco",50));

b = CompositeView(w, Rect(30, 110, 410, 365));
v.drawFunc = {
	Pen.strokeColor_(Color.fromHexString("#E6E7F2").alpha_(0.5));
	Pen.width_(3);
	Pen.strokeRect(Rect(30, 110, 435, 365));
	Pen.strokeRect(Rect(480, 110, 290, 365));
	Pen.strokeRect(Rect(320, 110, 145, 270));
	Pen.fillStroke;
};
~envLabel = StaticText(b, Rect(20, 25, 260, 20)).string_("AMPLITUDE ENVELOPE").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the knob, the numerical box and the label for amplitude envelope attack

~attAmpKnob = Knob(b, Rect(20, 65, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attAmpKnob.action_({
	arg obj;
	var atk = obj.value.linexp(0, 1, 0.001, 10);
	~attAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};
});

~attAmpBox = NumberBox(b, Rect(55, 65, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attAmpBox.action_({
	arg obj;
	~attAmpKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attAmpLabel = StaticText(b, Rect(55, 45, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for amplitude envelope release

~relAmpKnob = Knob(b, Rect(155, 65, 30, 30)).value_(0.2.explin(0.001, 10, 0, 1));
~relAmpKnob.action_({
	arg obj;
	var rel = obj.value.linexp(0, 1, 0.001, 10);
	~relAmpBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\rel, rel);
		};
	};
});

~relAmpBox = NumberBox(b, Rect(190, 65, 80, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.2);
~relAmpBox.action_({
	arg obj;
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
	~vibFreBox.value_(obj.value.linlin(0, 1, 0.1, 6));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\vfr, vfr);
		};
	};
});

~vibFreBox = NumberBox(b, Rect(55, 185, 80, 30)).clipLo_(0.1).clipHi_(6).decimals_(1).value_(5);
~vibFreBox.action_({
	arg obj;
	~vibFreKnob.valueAction_(obj.value.linlin(0.1, 6, 0, 1));
});

~vibFreLabel = StaticText(b, Rect(55,165 , 80, 20)).string_("Frequency (Hz)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for vibrato depth

~vibDepKnob = Knob(b, Rect(155, 185, 30, 30)).value_(30.linlin(0, 100, 0, 1));
~vibDepKnob.action_({
	arg obj;
	var vdep = obj.value.linlin(0, 1, 0, 100);
	~vibDepBox.value_(obj.value.linlin(0, 1, 0, 100));
	~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\vdep, vdep);
		};
	};
});

~vibDepBox = NumberBox(b, Rect(190, 185, 80, 30)).clipLo_(0).clipHi_(100).decimals_(0).value_(30);
~vibDepBox.action_({
	arg obj;
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


//for drum kit
k = CompositeView(w, Rect(480, 110, 290, 365)); //.background_(Color.new255(120, 120, 120, 210));

// KICK
~kickLabel= StaticText(k, Rect(20, 10, 290, 23)).string_("KICK").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the slider, the numerical box and the label for master of kick
~masterKickSlider = Slider.new(k, Rect(20, 95, 200, 20)).orientation_(\horizontal).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5));
~masterKickSlider.action_({
	arg obj;
	var masterK = obj.value.linlin(0, 1, 0, 100);
	~masterKickBox.value_(obj.value.linlin(0, 1, 0, 100));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~masterKickBox = NumberBox(k, Rect(230, 95, 35, 20)).clipLo_(0).clipHi_(100).decimals_(0).value_(0);
~masterKickBox.action_({
	arg obj;
	~masterKickSlider.valueAction_(obj.value.linlin(0, 1, 0, 100));
});

~masterKickLabel = StaticText(k, Rect(230, 75, 80, 20)).string_("Master").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for attack of kick
~attKickKnob = Knob(k, Rect(20, 50, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attKickKnob.action_({
	arg obj;
	var attK = obj.value.linexp(0, 1, 0.001, 10);
	~attKickBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});

~attKickBox = NumberBox(k, Rect(55, 50, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attKickBox.action_({
	arg obj;
	~attKickKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attKickLabel = StaticText(k, Rect(55, 30, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for release of kick
~relKickKnob = Knob(k, Rect(125, 50, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~relKickKnob.action_({
	arg obj;
	var relK = obj.value.linexp(0, 1, 0.001, 10);
	~relKickBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~relKickBox = NumberBox(k, Rect(160, 50, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~relKickBox.action_({
	arg obj;
	~relKickKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~relKickLabel = StaticText(k, Rect(160, 30, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

//listen default sound of kick
~buttonKick = Button(k, Rect(240, 35, 25, 25));
~buttonKick.states_([
	["▶", Color.black, Color.white],
	["￭", Color.white, Color.black] ]);
~buttonKick.font = Font("Monaco", 20);
~buttonKick.action_({
	arg objK;
	if(objK.value == 1) {
		TempoClock.default.tempo = 2.1;
		a=Pdef(\kick, Pbind(
			\instrument, "kick",
			\dur, Pseq([
				3/4, 1/4,
				1/2, 1/2,
				Rest(1/2), 1/2,
				Rest(1/4), 3/4
			], 3) * 0.5,
			\amp, 0.4,
			\rel, 0.5,
			\glissf, 0.9
		));
		a.play;
	}
	{a.stop;};
});

// SNARE
~snareLabel= StaticText(k, Rect(20, 130, 290, 23)).string_("SNARE").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the slider, the numerical box and the label for master of snare
~masterSnareSlider = Slider.new(k, Rect(20, 215, 200, 20)).orientation_(\horizontal).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5));
~masterSnareSlider.action_({
	arg obj;
	var masterS = obj.value.linlin(0, 1, 0, 100);
	~masterSnareBox.value_(obj.value.linlin(0, 1, 0, 100));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~masterSnareBox = NumberBox(k, Rect(230, 215, 35, 20)).clipLo_(0).clipHi_(100).decimals_(0).value_(0);
~masterSnareBox.action_({
	arg obj;
	~masterSnareSlider.valueAction_(obj.value.linlin(0, 1, 0, 100));
});

~masterSnareLabel = StaticText(k, Rect(230, 195, 80, 20)).string_("Master").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

~attSnareKnob = Knob(k, Rect(20, 170, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attSnareKnob.action_({
	arg obj;
	var attS = obj.value.linexp(0, 1, 0.001, 10);
	~attSnareBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
// creates the knob, the numerical box and the label for attack of snare
~attSnareBox = NumberBox(k, Rect(55, 170, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attSnareBox.action_({
	arg obj;
	~attSnareKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attSnareLabel = StaticText(k, Rect(55, 150, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for release of snare
~relSnareKnob = Knob(k, Rect(125, 170, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~relSnareKnob.action_({
	arg obj;
	var relS = obj.value.linexp(0, 1, 0.001, 10);
	~relSnareBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~relSnareBox = NumberBox(k, Rect(160, 170, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~relSnareBox.action_({
	arg obj;
	~relSnareKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~relSnareLabel = StaticText(k, Rect(160, 150, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

//listen default sound of snare
~buttonSnare = Button(k, Rect(240, 155, 25, 25));
~buttonSnare.states_([
	["▶", Color.black, Color.white],
	["￭", Color.white, Color.black] ]);
~buttonSnare.font = Font("Monaco", 20);
~buttonSnare.action_({
	arg objS;
	if(objS.value == 1) {
		TempoClock.default.tempo = 2.1;
		c=Pdef(\snare, Pbind(
			\instrument, "snare",
			\dur, Pseq([ Pseq([Pn(1/16, 3), 1/3, Rest(1/3)], 2), Pn(1/12, 3), Pn(1/3, 3) ], 1),
			\amp, 0.25,
			\rel, 0.1
		));

		c.play;
		}
		{c.stop;};
});


// HIHAT
~hihatLabel= StaticText(k, Rect(20, 250, 290, 23)).string_("HI-HAT").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

// creates the slider, the numerical box and the label for master of hihat
~masterHihatSlider = Slider.new(k, Rect(20, 335, 200, 20)).orientation_(\horizontal).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5));
~masterHihatSlider.action_({
	arg obj;
	var masterS = obj.value.linlin(0, 1, 0, 100);
	~masterHihatBox.value_(obj.value.linlin(0, 1, 0, 100));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~masterHihatBox = NumberBox(k, Rect(230, 335, 35, 20)).clipLo_(0).clipHi_(100).decimals_(0).value_(0);
~masterHihatBox.action_({
	arg obj;
	~masterHihatSlider.valueAction_(obj.value.linlin(0, 1, 0, 100));
});

~masterHihatLabel = StaticText(k, Rect(230, 315, 80, 20)).string_("Master").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for attack of hihat
~attHihatKnob = Knob(k, Rect(20, 290, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~attHihatKnob.action_({
	arg obj;
	var attS = obj.value.linexp(0, 1, 0.001, 10);
	~attHihatBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});

~attHihatBox = NumberBox(k, Rect(55, 290, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~attHihatBox.action_({
	arg obj;
	~attHihatKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~attHihatLabel = StaticText(k, Rect(55, 270, 80, 20)).string_("Attack (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

// creates the knob, the numerical box and the label for release of hihat
~relHihatKnob = Knob(k, Rect(125, 290, 30, 30)).value_(0.1.explin(0.001, 10, 0, 1));
~relHihatKnob.action_({
	arg obj;
	var relS = obj.value.linexp(0, 1, 0.001, 10);
	~relHihatBox.value_(obj.value.linexp(0, 1, 0.001, 10));
	/*~notes.do{
		arg synth;
		if(synth.isPlaying){
			synth.set(\atk, atk);
		};
	};*/
});
~relHihatBox = NumberBox(k, Rect(160, 290, 55, 30)).clipLo_(0.001).clipHi_(10).decimals_(3).value_(0.1);
~relHihatBox.action_({
	arg obj;
	~relHihatKnob.valueAction_(obj.value.explin(0.001, 10, 0, 1));
});

~relHihatLabel = StaticText(k, Rect(160, 270, 80, 20)).string_("Release (s)").align_(\left).stringColor_(Color.white).font_(Font("Monaco",11));

//listen default sound of hihat
~buttonHihat = Button(k, Rect(240, 275, 25, 25));
~buttonHihat.states_([
	["▶", Color.black, Color.white],
	["￭", Color.white, Color.black] ]);
~buttonHihat.font = Font("Monaco", 20);
~buttonHihat.action_({
	arg objH;
	if(objH.value == 1) {
		TempoClock.default.tempo = 2.1;
		d = Pdef(\hihat, Pbind(
			\instrument, "hihat",
			\dur, Pseq([ 1, 1, 1, 1, Prand([1, 1, Pn(0.5, 2)], 4) ], 2) * 0.2,
			\ffreq, Pwhite(7000, 11000),
			\rel, 0.1,
			\amp, 0.5
		));
		d.play;
		}
		{d.stop;};
});


// VOLUME
~volumeLabel= StaticText(b, Rect(335, 230, 290, 23)).string_("VOLUME").align_(\left).stringColor_(Color.white).font_(Font("Monaco",13));

~volumeSlider = Slider.new(b, Rect(315, 25, 30, 200)).orientation_(\vertical).background_(Color.fromHexString("#E6E7F2")).focusColor_(Color.blue(alpha:0.5)).value_(0.5);
/*~volSlider.action_({
	arg obj;
	~control_amp = obj.value;
});*/

ServerMeterView.new(s, b, 350@10, 0, 2);




)