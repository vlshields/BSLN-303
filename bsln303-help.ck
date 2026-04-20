// BSLN303 
// a Chugraph UGen that emulates the historical acid synthesizer.
// Saw/square oscillator -> resonant low-pass filter -> VCA, with twin
// envelopes (VEG for amplitude, MEG for filter) and an accent-sweep circuit.

// ~options
//
// noteOn (int midi, int velocity)
//   triggers a note; velocity > 100 sets accent
//
// noteOff (int midi)
//   releases a held note; does not gate the envelopes
//
// cutoff (float v), default 0.3
//   base filter cutoff, maps 80 Hz -> 8 kHz exponentially
//
// resonance (float v), default 0.55
//   filter Q, also smooths the accent sweep
//
// envMod (float v), default 0.65
//   MEG depth into filter cutoff (~10% residual at 0)
//
// decay (float v), default 0.3
//   MEG decay time on non-accented notes, 80 ms -> 2 s
//
// accent (float v), default 0.7
//   accent loudness and sweep intensity
//
// waveform (int w), default 0
//   0 = saw, 1 = square
//
// slide (int s), default 0
//   0 = retrigger each note, 1 = legato glide (requires note overlap)
//
// pitchBend (float p), default 1.0
//   frequency multiplier applied after slide
//
// each setter has a no-arg getter with the same name

BSLN303 bl => dac;

bl.resonance(0.9);
bl.envMod(0.8);
bl.decay(0.2);

[57, 60, 64, 67] @=> int notes[];

for(0 => int i; i < notes.cap(); i++) {
    bl.noteOn(notes[i], 100);
    300::ms => now;
    bl.noteOff(notes[i]);
    100::ms => now;
}

bl.waveform(1);
bl.accent(0.9);

bl.noteOn(60, 120);
500::ms => now;
bl.noteOff(60);
500::ms => now;