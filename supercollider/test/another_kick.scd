(
SynthDef("kick1", {arg out = 0, amp = 0.3, sinFreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var gliss = XLine.kr(sinFreq, sinFreq*glissf, rel);
	var snd = SinOsc.ar(gliss);
	var env = Env.perc(att, rel).kr(doneAction: 2);
	snd = snd * env * amp;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "Bruno Tucunduva Ruviaro",
	category: \drums,
	tags: [\percussion, \kick]
)
).add;)
Pbindef(\kick1,
	\instrument, "kick1",
	\dur, Pseq([
		3/4, 1/4,
		1/2, 1/2,
		Rest(1/2), 1/2,
		Rest(1/4), 3/4
	], 3) * 0.5,
	\amp, 100,
	\rel, Pseq([0.9, Pn(0.15, 6), 0.6], inf),
	\glissf, Pseq([Pn(0.9, 7), 0.5], inf)
).play;

SynthDef("kick808", {arg out = 0, freq1 = 240, freq2 = 60, amp = 1, ringTime = 10, att = 0.001, rel = 1, dist = 0.5, pan = 0;
	var snd, env;
	snd = Ringz.ar(
		in: Impulse.ar(0), // single impulse
		freq: XLine.ar(freq1, freq2, 0.1),
		decaytime: ringTime);
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = (1.0 - dist) * snd + (dist * (snd.distort));
	snd = snd * env;
	Out.ar(out, Pan2.ar(snd, pan));
},
metadata: (
	credit: "unknown",
	category: \drums,
	tags: [\percussion, \kick, \808]
)
).add;
Pbindef(\kick808,
	\instrument, "kick808",
	\dur, Pseq([
		3/4, 1/4,
		1/2, 1/2,
		Rest(1/2), 1/2,
		Rest(1/4), 3/4
	], 2) * 0.4,
	\amp, 0.8,
	\rel, 0.7,
	\dist, Pseries(0.1, 0.1, 16)
).play;