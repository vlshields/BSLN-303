// ============================================
//  BSLN303 Chugraph UGen
//  inherits : Chugraph : UGen : Object
//   This UGen uses a saw/square oscillator through a resonant low-pass      
//   filter and VCA, driven by twin envelopes (VEG for amplitude, MEG for          
//   filter cutoff) and an accent-sweep circuit (diode + ganged pot + cap).
//  
// ============================================
//
//  API:
//    noteOn(int midi, int velocity)   // velocity > 100 = accent
//    noteOff(int midi)
//    cutoff(float 0..1)
//    resonance(float 0..1)
//    envMod(float 0..1)
//    decay(float 0..1)
//    accent(float 0..1)
//    waveform(int 0=saw, 1=square)
//    slide(int 0/1)                   // slide (portamento) mode
//    pitchBend(float)                 // frequency multiplier, 1.0 = no bend
// ============================================

public class BSLN303 extends Chugraph
{
    SawOsc saw;
    SqrOsc sqr;
    Gain oscMix => LPF filter => Gain vca => outlet;
    saw => oscMix;
    sqr => oscMix;

    0.9 => saw.gain;
    0.0 => sqr.gain;
    0 => int _waveform;

    220.0 => saw.freq;
    220.0 => sqr.freq;
    0.0 => vca.gain;            
    500.0 => filter.freq;
    2.0 => filter.Q;

    // knobs
    0.3  => float cutoffKnob;
    0.55 => float resonanceKnob;
    0.65 => float envModKnob;
    0.3  => float decayKnob;
    0.7  => float accentKnob;

    // envelope states
    0.0 => float vegLevel;
    0 => int vegStage;           // 0=off, 1=attack, 2=decay
    0.0 => float megLevel;
    0 => int megStage;

    0.0 => float accentCapVoltage;

    // note states
    0 => int currentNote;
    0 => int noteActive;
    0 => int isAccented;
    0 => int slideMode;
    0.0 => float currentPitch;
    0.0 => float targetPitch;
    1.0 => float bend;

    int heldNotes[128];
    0 => int heldCount;

    1::ms => dur tick;

    fun float cutoff(float v)    { v => cutoffKnob;    return v; }
    fun float cutoff()           { return cutoffKnob; }
    fun float resonance(float v) { v => resonanceKnob; return v; }
    fun float resonance()        { return resonanceKnob; }
    fun float envMod(float v)    { v => envModKnob;    return v; }
    fun float envMod()           { return envModKnob; }
    fun float decay(float v)     { v => decayKnob;     return v; }
    fun float decay()            { return decayKnob; }
    fun float accent(float v)    { v => accentKnob;    return v; }
    fun float accent()           { return accentKnob; }

    fun int waveform(int w) {
        w => _waveform;
        if(w == 1) { 0.0 => saw.gain; 0.9 => sqr.gain; }
        else       { 0.9 => saw.gain; 0.0 => sqr.gain; }
        return _waveform;
    }
    fun int waveform() { return _waveform; }

    fun int slide(int s) { s => slideMode; return s; }
    fun int slide()      { return slideMode; }

    fun float pitchBend(float p) { p => bend; return p; }
    fun float pitchBend()        { return bend; }

    fun void noteOn(int midi, int velocity) {
        if(!heldNotes[midi]) {
            1 => heldNotes[midi];
            heldCount + 1 => heldCount;
        }
        Std.mtof(midi) => targetPitch;

        if(velocity > 100) 1 => isAccented;
        else               0 => isAccented;

        if(slideMode && heldCount > 1) {
            // Slide: pitch glides, envelopes do NOT retrigger
            midi => currentNote;
            1 => noteActive;
        } else {
            targetPitch => currentPitch;
            midi => currentNote;
            1 => noteActive;
            0.0 => vegLevel; 1 => vegStage;
            0.0 => megLevel; 1 => megStage;
        }
    }

    fun void noteOff(int midi) {
        if(heldNotes[midi]) {
            0 => heldNotes[midi];
            heldCount - 1 => heldCount;
            if(heldCount < 0) 0 => heldCount;
        }
        if(heldCount == 0) 0 => noteActive;
        // leave isAccented alone: it still shapes the tail of the active note
    }

    fun float mapCutoff(float n) { return 80.0 * Math.pow(100.0, n); }
    fun float mapQ(float n)      { return 0.7 + n * n * 24.3; }

    fun void modEngine() {
        while(true) {
            // --- VEG ---
            if(vegStage == 1) {
                vegLevel + 0.5 => vegLevel;
                if(vegLevel >= 1.0) { 1.0 => vegLevel; 2 => vegStage; }
            } else if(vegStage == 2) {
                vegLevel * 0.998 => vegLevel;         
                if(vegLevel < 0.0005) { 0.0 => vegLevel; 0 => vegStage; }
            }

            if(megStage == 1) {
                megLevel + 0.5 => megLevel;
                if(megLevel >= 1.0) { 1.0 => megLevel; 2 => megStage; }
            } else if(megStage == 2) {
                if(isAccented) {
                    megLevel * 0.9876 => megLevel;    
                } else {
                    Math.exp(-1.0 / (80.0 + decayKnob * 1920.0)) => float factor;
                    megLevel * factor => megLevel;
                }
                if(megLevel < 0.001) { 0.0 => megLevel; 0 => megStage; }
            }

            0.0 => float accentSweepOut;
            if(isAccented && megLevel > 0.001) {
                megLevel * accentKnob => float driveVoltage;
                if(driveVoltage > accentCapVoltage) {
                    (47.0 + resonanceKnob * 100.0) => float tauMs;
                    (1.0 - Math.exp(-1.0 / tauMs)) => float chargeRate;
                    accentCapVoltage + (driveVoltage - accentCapVoltage) * chargeRate
                        => accentCapVoltage;
                }
            }
            accentCapVoltage * (1.0 - 0.01) => accentCapVoltage;  
            if(isAccented) {
                megLevel * accentKnob * (1.0 - resonanceKnob * 0.7) => float direct;
                accentCapVoltage * (0.3 + resonanceKnob * 0.7)     => float fromCap;
                direct + fromCap => accentSweepOut;
            }

            mapCutoff(cutoffKnob) => float fFreq;
            (0.1 + envModKnob * 0.9) => float effectiveEnvMod;
            fFreq + megLevel * effectiveEnvMod * 6000.0 => fFreq;
            fFreq + accentSweepOut * 10000.0 => fFreq;
            Math.max(20.0, Math.min(fFreq, 18000.0)) => fFreq;
            fFreq => filter.freq;
            mapQ(resonanceKnob) => filter.Q;

            vegLevel => float vcaOut;
            if(isAccented) vcaOut + megLevel * accentKnob * 0.35 => vcaOut;
            Math.min(vcaOut, 1.0) * 0.8 => vca.gain;

            if(slideMode && heldCount > 1) {
                currentPitch + (targetPitch - currentPitch) * 0.017 => currentPitch;
            } else {
                targetPitch => currentPitch;
            }
            currentPitch * bend => float finalPitch;
            finalPitch => saw.freq;
            finalPitch => sqr.freq;

            tick => now;
        }
    }

    spork ~ modEngine();
}