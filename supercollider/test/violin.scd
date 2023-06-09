(SynthDef(\violin, {
	arg
	//Standard Definitions
	freq = 440, gate = 1, amp = 1, pan = 0, out = 0, att = 0.1, dec = 0.1, sus = 0.5, rel = 0.1,
	//Vibrato Controls
	vRate = 4.6, vDepth = 0.02, vAtt = 0.15, vRateVar = 0.25, vDepthVar = 0.05,
	//PWM Controls (pwmMax and pwmMin are 0 - 1)
	pwmVarRate = 2, pwmMin = 0.7, pwmMax = 0.8, pwmRate = 5,
	//Other Controls
	bridgeFreq = 2500, scratchDepth = 0.15;

	var scratch, env, pwm, snd;

	scratch = 1.015 + Env.perc(att, dec * 1.25, scratchDepth).kr;

	env = Env.adsr(att, dec, sus, rel).kr(gate: gate, doneAction: 2);

	freq = Vibrato.kr(
		            freq: freq,
		            rate: vRate,
		            depth: vDepth,
	            	delay: (att + dec),
		            onset: vAtt,
		            rateVariation: vRateVar,
		            depthVariation: vDepthVar
            	);

	pwm = SinOsc.kr(freq: pwmRate, phase: Rand(0.0, 1.0)).range(pwmMin, pwmMax);
	pwm = pwm * LFNoise2.kr(pwmVarRate).range(0.2, 0.8);

	snd = VarSaw.ar(
		freq: Lag.kr(freq) * LFPulse.ar(freq * 1.5).range(1/scratch, scratch),
		width: pwm,
		mul: amp
	);

	snd = (snd * 0.7) + BPF.ar(snd, bridgeFreq, 2, 2);
	snd = snd + HPF.ar(snd, bridgeFreq * 2);
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Original by nicolaariutti, modified by Josh Mitchell",
	category: \strings,
	tags: [\bowed, \pitched, \violin]
	)
).add;
)

(
Pbindef(\violin,
	\instrument, \violin,
	\dur, Pseq([
		3/8, 1/8, // m. 1
		1/4 + 0.1, 3/8 + 0.1, 1/8, // m. 2
		1/4, 3/8 // m. 3
	]) * 4,
	\strum, 0.05,
    \midinote, Pseq([
		[62, 65, 69], 69,
		[62, 67, 70, 76],
		[61, 67, 69, 76], 76,
		[62, 69, 74, 77],
		[58, 65, 70, 74]
	]),
).play;

)

(
p = Pbind(
	\instrument, \violin,
	\dur, 3,
	\legato, 1,
	\freq,880
).play;
)
x = Synth(\violin);
