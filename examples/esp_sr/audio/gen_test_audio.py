"""Generate test audio for AEC validation.

far_end.raw   - "Twinkle Twinkle Little Star" melody (square-ish tone, 16kHz 16bit mono)
near_end.raw  - 1kHz sine wave (continuous, for waveform consistency check after AEC)

3 seconds each = 48000 samples = 96000 bytes.
"""

import struct
import math
import os

SAMPLE_RATE = 16000
DURATION_S = 3
N_SAMPLES = SAMPLE_RATE * DURATION_S
AMPLITUDE = 12000

out_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "src")

# Twinkle Twinkle Little Star - note frequencies (Hz) and durations (beats)
# C C G G A A G | F F E E D D C | G G F F E E D | G G F F E E D
# C4=262, D4=294, E4=330, F4=349, G4=392, A4=440
MELODY = [
    # "Twinkle twinkle little star"
    (262, 0.4), (262, 0.4), (392, 0.4), (392, 0.4),
    (440, 0.4), (440, 0.4), (392, 0.8),
    # "How I wonder what you are"
    (349, 0.4), (349, 0.4), (330, 0.4), (330, 0.4),
    (294, 0.4), (294, 0.4), (262, 0.8),
]


def gen_far_end():
    """Twinkle Twinkle melody with harmonics (square-ish wave)."""
    samples = []
    t = 0.0
    note_idx = 0
    melody_time = 0.0

    for _ in range(N_SAMPLES):
        if note_idx < len(MELODY):
            freq, dur = MELODY[note_idx]
            if melody_time >= dur:
                melody_time = 0.0
                note_idx += 1
        else:
            note_idx = 0
            melody_time = 0.0

        if note_idx < len(MELODY):
            freq = MELODY[note_idx][0]
            phase = 2 * math.pi * freq * t
            # fundamental + 3rd harmonic for richer timbre
            val = AMPLITUDE * (math.sin(phase) + 0.3 * math.sin(3 * phase))
            samples.append(max(-32768, min(32767, int(val))))
        else:
            samples.append(0)

        t += 1.0 / SAMPLE_RATE
        melody_time += 1.0 / SAMPLE_RATE

    return samples


def gen_near_end():
    """Continuous 1kHz sine wave for waveform consistency verification."""
    samples = []
    for i in range(N_SAMPLES):
        t = i / SAMPLE_RATE
        val = int(AMPLITUDE * math.sin(2 * math.pi * 1000 * t))
        samples.append(max(-32768, min(32767, val)))
    return samples


def write_raw(path, samples):
    with open(path, "wb") as f:
        for s in samples:
            f.write(struct.pack("<h", s))
    print(f"  {path}: {len(samples)} samples, {len(samples)*2} bytes")


far = gen_far_end()
near = gen_near_end()

print("Generating test audio:")
write_raw(os.path.join(out_dir, "far_end.raw"), far)
write_raw(os.path.join(out_dir, "near_end.raw"), near)
print("Done.")
