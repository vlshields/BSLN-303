# BSLN303

inherits : Chugraph : UGen : Object

This Chugraph UGen emulates the historical acid synthesizer. It uses a saw/square oscillator through a resonant low-pass filter and VCA, driven by twin envelopes (VEG for amplitude, MEG for filter cutoff) and an accent-sweep circuit (diode + ganged pot + cap). Velocity > 100 triggers accent. by Vince Shields, 2026.

## examples

- bsln303-help.ck

## constructors

**BSLN303()**

Default constructor for BSLN303.

## member functions

**void noteOn(int midi, int velocity)**

Trigger a note; velocity > 100 sets accent.

**void noteOff(int midi)**

Release a held note; does not gate the envelopes.

**float cutoff(float value)**

Set base filter cutoff, [0.0-1.0]. Maps 80 Hz to 8 kHz exponentially.

**float cutoff()**

Get base filter cutoff, [0.0-1.0].

**float resonance(float value)**

Set filter Q, [0.0-1.0]. Also smooths the accent sweep.

**float resonance()**

Get filter Q, [0.0-1.0].

**float envMod(float value)**

Set MEG depth into filter cutoff, [0.0-1.0].

**float envMod()**

Get MEG depth into filter cutoff, [0.0-1.0].

**float decay(float value)**

Set MEG decay time on non-accented notes, [0.0-1.0]. Maps 80 ms to 2 s.

**float decay()**

Get MEG decay time, [0.0-1.0].

**float accent(float value)**

Set accent loudness and sweep intensity, [0.0-1.0].

**float accent()**

Get accent loudness and sweep intensity, [0.0-1.0].

**int waveform(int w)**

Set oscillator waveform, 0 = saw, 1 = square.

**int waveform()**

Get oscillator waveform.

**int slide(int s)**

Set slide (portamento) mode, 0 = retrigger each note, 1 = legato glide (requires note overlap).

**int slide()**

Get slide mode.

**float pitchBend(float value)**

Set pitch bend as a frequency multiplier applied after slide, 1.0 = no bend.

**float pitchBend()**

Get pitch bend multiplier.
