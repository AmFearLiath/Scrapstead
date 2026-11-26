"""Synthesises all Scrapstead sounds and music from code (no samples, no downloads).

    python tools/audio/synth_audio.py

Writes 16-bit mono WAV files to assets/audio/{sfx,music,ambience}/ and the
sound library resource data/audio/sound_library.tres. Everything is seeded and
reproducible. Style: warm, wooden, slightly wonky (docs/world-art-assets.md).
"""
import os
import sys

import numpy as np
from scipy import signal
from scipy.io import wavfile

SR = 32000
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
rng = np.random.default_rng(1974)


# --- Basic building blocks -------------------------------------------------------

def t_axis(seconds):
    return np.arange(int(seconds * SR)) / SR


def env_exp(seconds, decay, attack=0.004):
    t = t_axis(seconds)
    env = np.exp(-t / decay)
    attack_samples = max(1, int(attack * SR))
    env[:attack_samples] *= np.linspace(0, 1, attack_samples)
    return env


def noise(seconds):
    return rng.uniform(-1, 1, int(seconds * SR))


def bandpass(x, low, high, order=2):
    b, a = signal.butter(order, [low / (SR / 2), min(high / (SR / 2), 0.99)], btype="band")
    return signal.lfilter(b, a, x)


def lowpass(x, cutoff, order=2):
    b, a = signal.butter(order, min(cutoff / (SR / 2), 0.99), btype="low")
    return signal.lfilter(b, a, x)


def highpass(x, cutoff, order=2):
    b, a = signal.butter(order, cutoff / (SR / 2), btype="high")
    return signal.lfilter(b, a, x)


def layer(*parts):
    """Sums sounds of different lengths (shorter ones are zero padded)."""
    length = max(len(part) for part in parts)
    out = np.zeros(length)
    for part in parts:
        out[: len(part)] += part
    return out


def mix_into(buffer, sound, start_seconds, gain=1.0):
    start = int(start_seconds * SR)
    if start >= len(buffer):
        return
    end = min(len(buffer), start + len(sound))
    buffer[start:end] += sound[: end - start] * gain


def midi_hz(note):
    return 440.0 * 2 ** ((note - 69) / 12.0)


NOTE = {"C": 0, "C#": 1, "Db": 1, "D": 2, "D#": 3, "Eb": 3, "E": 4, "F": 5, "F#": 6, "Gb": 6, "G": 7,
        "G#": 8, "Ab": 8, "A": 9, "A#": 10, "Bb": 10, "B": 11}


def n(name):
    """'C5' -> midi number."""
    pitch, octave = name[:-1], int(name[-1])
    return 12 * (octave + 1) + NOTE[pitch]


def reverb(x, seconds=0.9, wet=0.18, brightness=3500):
    impulse = noise(seconds) * np.exp(-t_axis(seconds) / (seconds / 5))
    impulse = lowpass(impulse, brightness)
    impulse[0] = 0
    tail = signal.fftconvolve(x, impulse)[: len(x)]
    tail *= np.max(np.abs(x)) / (np.max(np.abs(tail)) + 1e-9)
    return x * (1 - wet) + tail * wet


def reverb_loop(x, seconds=0.9, wet=0.18, brightness=3500):
    """Reverb for loops: the tail wraps around so the seam stays continuous."""
    doubled = reverb(np.concatenate([x, x]), seconds, wet, brightness)
    return doubled[len(x):]


def finish(x, peak_db=-1.0, fade_out=0.01, fade_in=0.002):
    x = np.tanh(x * 1.2) / np.tanh(1.2)
    if fade_in:
        k = int(fade_in * SR)
        x[:k] *= np.linspace(0, 1, k)
    if fade_out:
        k = int(fade_out * SR)
        x[-k:] *= np.linspace(1, 0, k)
    peak = np.max(np.abs(x)) + 1e-9
    return x / peak * 10 ** (peak_db / 20)


def write(path, x):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    wavfile.write(path, SR, (np.clip(x, -1, 1) * 32767).astype(np.int16))


# --- Instruments -----------------------------------------------------------------------

def marimba(freq, seconds=0.9, velocity=1.0):
    t = t_axis(seconds)
    tone = (np.sin(2 * np.pi * freq * t) * np.exp(-t / 0.45)
            + 0.28 * np.sin(2 * np.pi * freq * 3.93 * t) * np.exp(-t / 0.09)
            + 0.06 * np.sin(2 * np.pi * freq * 9.2 * t) * np.exp(-t / 0.03))
    click = bandpass(noise(0.01), 1500, 6000) * 0.3
    tone[: len(click)] += click
    attack = int(0.003 * SR)
    tone[:attack] *= np.linspace(0, 1, attack)
    return tone * velocity


def music_box(freq, seconds=2.2, velocity=1.0):
    t = t_axis(seconds)
    tone = (np.sin(2 * np.pi * freq * t) * np.exp(-t / 0.9)
            + 0.35 * np.sin(2 * np.pi * freq * 2.76 * t) * np.exp(-t / 0.35)
            + 0.12 * np.sin(2 * np.pi * freq * 5.4 * t) * np.exp(-t / 0.12))
    attack = int(0.002 * SR)
    tone[:attack] *= np.linspace(0, 1, attack)
    return tone * velocity


def pluck(freq, seconds=1.0, brightness=0.5, decay=0.996):
    """Karplus-Strong string (ukulele / guitar-ish)."""
    period = max(2, int(SR / freq))
    total = int(seconds * SR)
    buffer = lowpass(rng.uniform(-1, 1, period), 1500 + 6000 * brightness)
    out = np.zeros(total)
    ring = buffer.copy()
    position = 0
    for index in range(total):
        current = ring[position]
        nxt = ring[(position + 1) % period]
        ring[position] = decay * 0.5 * (current + nxt)
        out[index] = current
        position = (position + 1) % period
    return out * np.exp(-t_axis(seconds) / (seconds * 0.6))


def upright_bass(freq, seconds=0.7, velocity=1.0):
    t = t_axis(seconds)
    tone = np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * 2 * freq * t) + 0.1 * np.sin(
        2 * np.pi * 3 * freq * t)
    env = np.exp(-t / 0.35)
    attack = int(0.008 * SR)
    env[:attack] *= np.linspace(0, 1, attack)
    thump = lowpass(noise(0.03), 400) * np.linspace(1, 0, int(0.03 * SR)) * 0.4
    tone = tone * env
    tone[: len(thump)] += thump
    return lowpass(tone, 900) * velocity


def pad(freqs, seconds):
    t = t_axis(seconds)
    tone = np.zeros(len(t))
    for freq in freqs:
        for detune in (-0.12, 0.0, 0.11):
            f = freq * 2 ** (detune / 12)
            tone += signal.sawtooth(2 * np.pi * f * t + rng.uniform(0, 6.28))
    tone = lowpass(tone, 1100, order=2)
    env = np.minimum(1, t / 0.6) * np.minimum(1, (seconds - t) / 0.6)
    return tone * env / (len(freqs) * 3)


def shaker(seconds=0.09, velocity=1.0):
    return highpass(noise(seconds), 5000) * env_exp(seconds, 0.025, attack=0.006) * velocity


def soft_kick(velocity=1.0):
    t = t_axis(0.3)
    freq = 45 + 70 * np.exp(-t / 0.04)
    phase = 2 * np.pi * np.cumsum(freq) / SR
    return np.sin(phase) * np.exp(-t / 0.12) * velocity


def woodblock(freq=900, velocity=1.0):
    t = t_axis(0.12)
    tone = np.sin(2 * np.pi * freq * t) * np.exp(-t / 0.025) + 0.4 * np.sin(2 * np.pi * freq * 2.3 * t) * np.exp(
        -t / 0.012)
    return tone * velocity


def metal_clank(freq=520, seconds=0.6, velocity=1.0):
    t = t_axis(seconds)
    partials = [(1.0, 1.0, 0.25), (2.41, 0.6, 0.15), (3.83, 0.45, 0.1), (5.2, 0.3, 0.07), (7.1, 0.2, 0.05)]
    tone = sum(a * np.sin(2 * np.pi * freq * r * t + rng.uniform(0, 6)) * np.exp(-t / d) for r, a, d in partials)
    click = highpass(noise(0.008), 2000)
    tone[: len(click)] += click * 0.8
    return tone * velocity


# --- Music -----------------------------------------------------------------------

CHORDS = {
    "F": ["F3", "A3", "C4"], "Dm": ["D3", "F3", "A3"], "Bb": ["Bb2", "D3", "F3"], "C": ["C3", "E3", "G3"],
    "Am": ["A2", "C3", "E3"], "Gm": ["G2", "Bb2", "D3"], "C7": ["C3", "E3", "Bb3"],
}
ROOTS = {"F": "F2", "Dm": "D2", "Bb": "Bb1", "C": "C2", "Am": "A1", "Gm": "G1", "C7": "C2"}
FIFTHS = {"F": "C3", "Dm": "A2", "Bb": "F2", "C": "G2", "Am": "E2", "Gm": "D2", "C7": "G2"}


def render_loop(bars, beats_per_bar, bpm, tail, render_bar):
    beat = 60.0 / bpm
    length = bars * beats_per_bar * beat
    buffer = np.zeros(int((length + tail) * SR))
    for bar in range(bars):
        render_bar(buffer, bar, bar * beats_per_bar * beat, beat)
    loop = buffer[: int(length * SR)].copy()
    wrapped = buffer[int(length * SR):]
    loop[: len(wrapped)] += wrapped  # tails continue into the loop start: seamless
    return loop


def old_yard_shuffle():
    """Gameplay loop: 96 BPM swing shuffle in F, marimba melody, ukulele offbeats,
    upright bass, brushes, a woodblock and the occasional scrapyard 'clank'."""
    bpm = 96
    progression = ["F", "Dm", "Bb", "C", "F", "Am", "Bb", "C",
                   "Bb", "F", "Gm", "C", "Am", "Dm", "Gm", "C7"]
    # Melody per bar: (beat, note, length in beats). The motif rises and lands
    # a little off, like Walt's repairs.
    melody = [
        [(0, "C5", 1), (1, "A4", 0.66), (1.66, "C5", 0.34), (2, "D5", 1), (3, "C5", 1)],
        [(0, "A4", 1.5), (2, "F4", 1), (3, "A4", 1)],
        [(0, "Bb4", 0.66), (0.66, "D5", 0.34), (1, "F5", 1), (2, "D5", 1), (3, "Bb4", 1)],
        [(0, "C5", 2), (2.66, "E4", 0.34), (3, "G4", 1)],
        [(0, "C5", 1), (1, "A4", 0.66), (1.66, "C5", 0.34), (2, "F5", 1), (3, "E5", 1)],
        [(0, "C5", 1.5), (2, "A4", 0.66), (2.66, "B4", 0.34), (3, "C5", 1)],
        [(0, "D5", 1), (1, "Bb4", 1), (2, "G4", 0.66), (2.66, "A4", 0.34), (3, "Bb4", 1)],
        [(0, "A4", 1), (1, "G4", 1), (2, "C5", 2)],
        [(0, "D5", 1), (1, "F5", 0.66), (1.66, "D5", 0.34), (2, "Bb4", 2)],
        [(0, "C5", 0.66), (0.66, "A4", 0.34), (1, "F4", 1), (2.66, "A4", 0.34), (3, "C5", 1)],
        [(0, "Bb4", 1), (1, "D5", 1), (2, "G5", 1), (3, "F5", 1)],
        [(0, "E5", 2), (2, "D5", 0.66), (2.66, "C5", 0.34), (3, "Bb4", 1)],
        [(0, "A4", 1), (1, "C5", 1), (2, "E5", 1), (3, "A5", 1)],
        [(0, "F5", 1.5), (2, "D5", 1), (3, "A4", 1)],
        [(0, "G4", 0.66), (0.66, "A4", 0.34), (1, "Bb4", 1), (2, "D5", 0.66), (2.66, "E5", 0.34), (3, "G5", 1)],
        [(0, "F5", 1), (1, "E5", 0.66), (1.66, "C5", 0.34), (2, "E5", 1), (3, "G5", 1)],
    ]

    def render_bar(buffer, bar, start, beat):
        chord = progression[bar % 16]
        swing = 0.66 * beat  # swung second eighth
        # Bass: root on 1, fifth on 3, approach note on the 'and' of 4 every other bar.
        mix_into(buffer, upright_bass(midi_hz(n(ROOTS[chord]))), start, 0.55)
        mix_into(buffer, upright_bass(midi_hz(n(FIFTHS[chord]))), start + 2 * beat, 0.5)
        if bar % 2 == 1:
            next_root = n(ROOTS[progression[(bar + 1) % 16]])
            mix_into(buffer, upright_bass(midi_hz(next_root - 1), 0.3), start + 3 * beat + swing, 0.35)
        # Ukulele: short strums on beats 2 and 4 plus a ghost strum.
        for strum_beat, gain in ((1, 0.32), (3, 0.32), (3.66, 0.14)):
            for index, note in enumerate(CHORDS[chord]):
                mix_into(buffer, pluck(midi_hz(n(note) + 12), 0.45, brightness=0.55),
                         start + strum_beat * beat + index * 0.012, gain)
        # Brushes and a soft kick.
        for eighth in range(4):
            mix_into(buffer, shaker(velocity=0.55), start + eighth * beat, 0.5)
            mix_into(buffer, shaker(velocity=0.35), start + eighth * beat + swing, 0.5)
        mix_into(buffer, soft_kick(), start, 0.45)
        mix_into(buffer, soft_kick(0.6), start + 2 * beat, 0.35)
        if bar % 4 == 3:
            mix_into(buffer, woodblock(1100), start + 3 * beat + swing, 0.25)
        if bar % 8 == 7:
            mix_into(buffer, metal_clank(430, 0.8), start + 3 * beat, 0.16)
        # Melody.
        for beat_offset, note, length in melody[bar % 16]:
            mix_into(buffer, marimba(midi_hz(n(note)), seconds=max(0.5, length * beat + 0.2)),
                     start + beat_offset * beat, 0.42)
        # Warm pad in the second half.
        if bar >= 8:
            mix_into(buffer, pad([midi_hz(n(note) + 12) for note in CHORDS[chord]], 4 * beat + 0.3), start, 0.11)

    loop = render_loop(32, 4, bpm, 2.5, lambda b, bar, s, beat: render_bar(b, bar, s, beat))
    return finish(reverb_loop(loop, 1.1, 0.16), peak_db=-2.0, fade_out=0, fade_in=0)


def every_scrap_has_a_story():
    """Menu theme: 72 BPM, the gameplay motif on a music box over a soft pad and
    plucked bass. Calm, a little wistful, with a wink."""
    bpm = 72
    progression = ["F", "Am", "Bb", "C", "Dm", "Bb", "Gm", "C7"]
    melody = [
        [(0, "C6", 1), (1, "A5", 1), (2, "C6", 0.5), (2.5, "D6", 1.5)],
        [(0, "C6", 1.5), (2, "A5", 1), (3, "E5", 1)],
        [(0, "F5", 1), (1, "Bb5", 1), (2, "D6", 2)],
        [(0, "C6", 3), (3, "G5", 1)],
        [(0, "A5", 1), (1, "D6", 1), (2, "F6", 1), (3, "E6", 1)],
        [(0, "D6", 2), (2, "Bb5", 1), (3, "F5", 1)],
        [(0, "G5", 1), (1, "Bb5", 1), (2, "D6", 1), (3, "C6", 0.5), (3.5, "Bb5", 0.5)],
        [(0, "A5", 2), (2, "G5", 1), (3, "C6", 1)],
    ]

    def render_bar(buffer, bar, start, beat):
        chord = progression[bar % 8]
        mix_into(buffer, pad([midi_hz(n(note)) for note in CHORDS[chord]], 4 * beat + 0.6), start, 0.32)
        mix_into(buffer, pluck(midi_hz(n(ROOTS[chord]) + 12), 1.6, brightness=0.25, decay=0.998), start, 0.5)
        mix_into(buffer, pluck(midi_hz(n(FIFTHS[chord]) + 12), 1.2, brightness=0.25, decay=0.998), start + 2 * beat,
                 0.35)
        for beat_offset, note, _length in melody[bar % 8]:
            mix_into(buffer, music_box(midi_hz(n(note))), start + beat_offset * beat, 0.38)
        if bar >= 8:
            for index, note in enumerate(CHORDS[chord]):
                mix_into(buffer, marimba(midi_hz(n(note) + 12), 0.6), start + (1 + index * 0.5) * beat, 0.12)
        if bar == 15:
            mix_into(buffer, metal_clank(880, 1.2), start + 3.5 * beat, 0.08)  # a tiny tin chime

    loop = render_loop(16, 4, bpm, 3.0, lambda b, bar, s, beat: render_bar(b, bar, s, beat))
    return finish(reverb_loop(loop, 1.8, 0.3, 2800), peak_db=-3.0, fade_out=0, fade_in=0)


def yard_ambience():
    """40 s loop: soft wind, distant birds, a faint creak now and then."""
    seconds = 40.0
    wind = lowpass(noise(seconds), 600, order=1)
    sway = 0.6 + 0.4 * np.sin(2 * np.pi * t_axis(seconds) / seconds * 3)
    out = wind * sway * 0.35
    for _ in range(14):
        start = rng.uniform(0, seconds - 1)
        for chirp in range(rng.integers(2, 5)):
            length = rng.uniform(0.06, 0.12)
            t = t_axis(length)
            base = rng.uniform(2800, 4200)
            freq = base + 1200 * np.sin(np.pi * t / length)
            tone = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.sin(np.pi * t / length) ** 2
            mix_into(out, tone, start + chirp * rng.uniform(0.1, 0.18), rng.uniform(0.05, 0.11))
    for start in (9.0, 27.5):
        t = t_axis(1.2)
        creak = signal.sawtooth(2 * np.pi * np.cumsum(180 + 40 * np.sin(t * 7)) / SR) * np.sin(np.pi * t / 1.2)
        mix_into(out, bandpass(creak, 300, 1500), start, 0.05)
    k = int(2.0 * SR)  # crossfade end into start for a seamless loop
    out[:k] = out[:k] * np.linspace(0, 1, k) + out[-k:] * np.linspace(1, 0, k)
    out = out[:-k]
    return finish(out, peak_db=-6.0, fade_out=0, fade_in=0)


# --- Sound effects ----------------------------------------------------------------------

def sfx_footstep(variant):
    x = lowpass(noise(0.11), 900 + variant * 150) * env_exp(0.11, 0.03, attack=0.004)
    x = layer(x, highpass(noise(0.05), 3000) * env_exp(0.05, 0.01) * 0.25)  # grit
    return finish(x, peak_db=-6, fade_out=0.01)


def sfx_clink(variant):
    return finish(metal_clank(700 + variant * 110, 0.45) * 0.9, peak_db=-4)


def sfx_tin(variant):
    x = metal_clank(1350 + variant * 160, 0.35)
    x = layer(x, bandpass(noise(0.05), 2000, 8000) * env_exp(0.05, 0.015) * 0.6)
    return finish(x, peak_db=-5)


def sfx_wire(variant):
    x = bandpass(noise(0.35), 1800, 7000) * env_exp(0.35, 0.09)
    x = layer(x, metal_clank(1900 + variant * 200, 0.2) * 0.2)
    return finish(x, peak_db=-7)


def sfx_wood(variant):
    x = layer(woodblock(320 + variant * 40), lowpass(noise(0.1), 1200) * env_exp(0.1, 0.02) * 0.5)
    return finish(x, peak_db=-4)


def sfx_brass(_variant):
    return finish(layer(metal_clank(980, 0.9) * 0.8, music_box(midi_hz(n("A6")), 0.8) * 0.3), peak_db=-5)


def sfx_box(variant):
    x = lowpass(noise(0.16), 500) * env_exp(0.16, 0.05) + soft_kick(0.6)[: int(0.16 * SR)] * 0.6
    x = layer(x, woodblock(260 + variant * 30) * 0.2)
    return finish(x, peak_db=-4)


def sfx_basket(variant):
    x = lowpass(noise(0.14), 700) * env_exp(0.14, 0.035)
    x = layer(x, bandpass(noise(0.1), 1500, 4000) * env_exp(0.1, 0.02) * 0.4)  # wicker creak
    x = layer(x, soft_kick(0.5)[: len(x)] * 0.4)
    return finish(x, peak_db=-6 - variant)


def sfx_thud(variant):
    x = soft_kick()[: int(0.25 * SR)] * 0.8 + lowpass(noise(0.25), 400) * env_exp(0.25, 0.06) * 0.6
    return finish(x, peak_db=-4 - variant)


def sfx_nope(_variant):
    """Polite refusal: a low, rubbery double bonk."""
    out = np.zeros(int(0.35 * SR))
    mix_into(out, woodblock(240), 0.0, 0.8)
    mix_into(out, woodblock(200), 0.12, 0.6)
    return finish(lowpass(out, 1800), peak_db=-6)


def sfx_bell(_variant):
    """The taped-up service bell: a ding with a slightly dull rattle."""
    x = metal_clank(1760, 1.6) * 0.8 + music_box(1760, 1.6) * 0.4
    rattle = bandpass(noise(0.08), 3000, 7000) * env_exp(0.08, 0.02)
    x[: len(rattle)] += rattle * 0.5
    return finish(reverb(x, 0.6, 0.15), peak_db=-5)


def sfx_kaching(_variant):
    out = np.zeros(int(1.3 * SR))
    mix_into(out, lowpass(noise(0.06), 2500) * env_exp(0.06, 0.015), 0.0, 0.6)  # drawer
    mix_into(out, woodblock(700), 0.02, 0.4)
    mix_into(out, music_box(midi_hz(n("E6")), 1.0), 0.12, 0.6)
    mix_into(out, music_box(midi_hz(n("A6")), 1.1), 0.18, 0.7)
    for index in range(6):  # coins
        mix_into(out, metal_clank(2400 + rng.uniform(-300, 400), 0.25), 0.22 + index * 0.05 + rng.uniform(0, 0.02),
                 0.25)
    return finish(out, peak_db=-3)


def sfx_coins(variant):
    out = np.zeros(int(0.8 * SR))
    for index in range(5 + variant * 2):
        mix_into(out, metal_clank(2200 + rng.uniform(-400, 600), 0.22), index * 0.06 + rng.uniform(0, 0.03), 0.3)
    return finish(out, peak_db=-6)


def sfx_page(variant):
    x = bandpass(noise(0.32), 1500, 6500) * (np.sin(np.pi * t_axis(0.32) / 0.32) ** 1.5)
    x *= 0.6 + 0.4 * np.sin(2 * np.pi * (25 + variant * 6) * t_axis(0.32))
    return finish(x, peak_db=-8)


def sfx_paper(_variant):
    out = np.zeros(int(0.5 * SR))
    for index in range(4):
        mix_into(out, bandpass(noise(0.07), 2000, 7000) * env_exp(0.07, 0.02), index * 0.09, 0.5)
    return finish(out, peak_db=-9)


def sfx_phone(_variant):
    """Rotary dial: a few clicks, a pause, more clicks, then a little bell."""
    out = np.zeros(int(1.5 * SR))
    position = 0.0
    for digits in (3, 5, 2):
        for _ in range(digits):
            mix_into(out, highpass(noise(0.01), 1500) * env_exp(0.01, 0.003), position, 0.5)
            position += 0.06
        position += 0.16
    mix_into(out, music_box(midi_hz(n("G6")), 0.5), position, 0.3)
    mix_into(out, music_box(midi_hz(n("G6")), 0.5), position + 0.11, 0.3)
    return finish(out, peak_db=-6)


def sfx_delivery(_variant):
    out = np.zeros(int(0.8 * SR))
    mix_into(out, sfx_thud(0), 0.0, 1.0)
    mix_into(out, metal_clank(300, 0.6), 0.05, 0.35)
    mix_into(out, lowpass(noise(0.4), 1200) * env_exp(0.4, 0.15), 0.02, 0.25)  # dust
    return finish(out, peak_db=-4)


def sfx_jingle(_variant):
    """Short happy arpeggio for a purchase."""
    out = np.zeros(int(1.4 * SR))
    for index, note in enumerate(("F5", "A5", "C6", "F6")):
        mix_into(out, marimba(midi_hz(n(note)), 0.9), index * 0.09, 0.6)
    mix_into(out, music_box(midi_hz(n("A6")), 1.0), 0.36, 0.25)
    return finish(reverb(out, 0.7, 0.2), peak_db=-4)


def sfx_switch(_variant):
    out = np.zeros(int(0.4 * SR))
    mix_into(out, highpass(noise(0.015), 2000) * env_exp(0.015, 0.004), 0.0, 0.8)
    t = t_axis(0.3)
    hum = (np.sin(2 * np.pi * 100 * t) + 0.5 * np.sin(2 * np.pi * 200 * t)) * np.minimum(1, t / 0.05) * np.exp(-t / 0.2)
    mix_into(out, hum, 0.03, 0.25)
    return finish(out, peak_db=-7)


def sfx_pop(variant):
    t = t_axis(0.12)
    freq = 500 + 900 * t / 0.12 + variant * 80
    x = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.exp(-t / 0.04)
    return finish(x, peak_db=-8)


def sfx_click(_variant):
    x = woodblock(1600)[: int(0.06 * SR)] * 0.6
    return finish(x, peak_db=-10)


def sfx_rummage(_variant):
    """1.6 s loop: digging through junk."""
    seconds = 1.6
    out = lowpass(noise(seconds), 1500) * 0.15
    for _ in range(9):
        start = rng.uniform(0, seconds - 0.3)
        kind = rng.integers(0, 3)
        sound = (metal_clank(rng.uniform(500, 1400), 0.3) if kind == 0 else
                 woodblock(rng.uniform(250, 500)) if kind == 1 else
                 bandpass(noise(0.12), 1500, 6000) * env_exp(0.12, 0.03))
        mix_into(out, sound, start, rng.uniform(0.25, 0.5))
    return finish(out, peak_db=-8, fade_out=0.02, fade_in=0.02)


def sfx_hoist(_variant):
    """1.2 s loop: ratchet clicks and a groaning beam."""
    seconds = 1.2
    out = np.zeros(int(seconds * SR))
    for index in range(10):
        mix_into(out, highpass(noise(0.012), 1800) * env_exp(0.012, 0.003), index * 0.12, 0.7)
        mix_into(out, metal_clank(1500, 0.08), index * 0.12, 0.15)
    t = t_axis(seconds)
    groan = signal.sawtooth(2 * np.pi * np.cumsum(70 + 15 * np.sin(2 * np.pi * 0.8 * t)) / SR)
    out += bandpass(groan, 120, 700) * 0.25 * (0.6 + 0.4 * np.sin(np.pi * t / seconds))
    return finish(out, peak_db=-7, fade_out=0.02, fade_in=0.02)


def sfx_screw(_variant):
    """1.2 s loop: screwdriver squeaks and tiny clicks."""
    seconds = 1.2
    out = np.zeros(int(seconds * SR))
    for index in range(4):
        t = t_axis(0.18)
        squeak = np.sin(2 * np.pi * np.cumsum(1800 + 600 * np.sin(np.pi * t / 0.18)) / SR) * np.sin(np.pi * t / 0.18)
        mix_into(out, squeak, index * 0.3, 0.25)
        mix_into(out, metal_clank(2600, 0.06), index * 0.3 + 0.2, 0.3)
    return finish(out, peak_db=-9, fade_out=0.02, fade_in=0.02)


def sfx_creak(_variant):
    t = t_axis(0.7)
    creak = signal.sawtooth(2 * np.pi * np.cumsum(160 + 60 * np.sin(t * 9)) / SR) * np.sin(np.pi * t / 0.7)
    return finish(bandpass(creak, 250, 1800), peak_db=-8)


def _beep(freq_start, freq_end, seconds, wobble=0.0):
    """Little robot syllable: a sine glide with a soft square edge."""
    t = t_axis(seconds)
    freq = np.linspace(freq_start, freq_end, len(t)) * (1 + wobble * np.sin(2 * np.pi * 28 * t))
    phase = 2 * np.pi * np.cumsum(freq) / SR
    tone = np.sin(phase) + 0.18 * np.sign(np.sin(phase))
    env = np.minimum(1, t / 0.008) * np.minimum(1, (seconds - t) / 0.02)
    return tone * env


def sfx_scrappy_chirp(variant):
    """Scrappy talking: two or three cheerful, slightly wonky syllables."""
    patterns = [
        [(820, 1150, 0.07), (1250, 980, 0.09)],
        [(700, 900, 0.06), (1000, 1300, 0.06), (1350, 1050, 0.1)],
        [(1100, 760, 0.08), (900, 1220, 0.11)],
        [(950, 950, 0.05), (1200, 1500, 0.07), (1000, 880, 0.08)],
    ]
    out = np.zeros(int(0.45 * SR))
    cursor = 0.0
    for start, end, seconds in patterns[variant % len(patterns)]:
        mix_into(out, _beep(start, end, seconds, wobble=0.02), cursor, 0.55)
        cursor += seconds + 0.025
    return finish(reverb(lowpass(out, 5000), 0.3, 0.1), peak_db=-9)


def sfx_head_beep(variant):
    """Dormant Scrappy in the heap: a weak, stuttering beep with a dying fall."""
    out = np.zeros(int(0.6 * SR))
    mix_into(out, _beep(1180 - variant * 60, 1120 - variant * 60, 0.06), 0.0, 0.5)
    mix_into(out, _beep(1180 - variant * 60, 1180 - variant * 60, 0.03), 0.09, 0.3)
    mix_into(out, _beep(1100, 640, 0.22), 0.16, 0.35)
    return finish(reverb(bandpass(out, 500, 3500), 0.4, 0.15), peak_db=-10)


def sfx_scrappy_wake(_variant):
    """Power-up: a rising hum, a stutter, then a pleased little chirp."""
    out = np.zeros(int(1.9 * SR))
    t = t_axis(0.9)
    freq = 60 + 420 * (t / 0.9) ** 2
    hum = np.sin(2 * np.pi * np.cumsum(freq) / SR) * np.minimum(1, t / 0.2)
    mix_into(out, lowpass(hum, 1200), 0.0, 0.5)
    for index in range(3):
        mix_into(out, _beep(500 + index * 120, 520 + index * 120, 0.04), 0.85 + index * 0.07, 0.35)
    mix_into(out, _beep(900, 1400, 0.09, 0.03), 1.15, 0.55)
    mix_into(out, _beep(1500, 1150, 0.12, 0.03), 1.27, 0.5)
    mix_into(out, music_box(midi_hz(n("C6")), 0.6), 1.3, 0.25)
    return finish(reverb(out, 0.6, 0.18), peak_db=-5)


def sfx_spark(variant):
    """Welding crackle: dense bright clicks over a short hiss."""
    seconds = 0.55
    hiss = highpass(noise(seconds), 3500) * env_exp(seconds, 0.18) * 0.35
    crackle = np.zeros(int(seconds * SR))
    local = np.random.default_rng(300 + variant)
    for _ in range(40):
        position = int(local.uniform(0, seconds * 0.85) * SR)
        length = int(0.003 * SR)
        crackle[position:position + length] += local.uniform(-1, 1, length) * local.uniform(0.3, 1.0)
    return finish(highpass(hiss + crackle, 1500), peak_db=-8)


def sfx_van_horn(_variant):
    """A small delivery van honking twice at the gate, slightly out of breath."""
    out = np.zeros(int(1.3 * SR))
    for start, length, freq in ((0.0, 0.16, 392.0), (0.24, 0.32, 370.0)):
        t = t_axis(length)
        tone = np.zeros_like(t)
        for detune in (1.0, 1.012):
            phase = (freq * detune * t) % 1.0
            tone += 2.0 * phase - 1.0  # sawtooth: nasal horn
        tone *= np.minimum(1.0, t / 0.015) * np.minimum(1.0, (length - t) / 0.03)
        tone = bandpass(tone, 300, 2200)
        mix_into(out, tone, start, 0.5)
    out = lowpass(out, 2400)  # a few metres away, behind the fence
    return finish(reverb(out, 0.7, 0.22), peak_db=-7)


def sfx_magnet_hum(_variant):
    """2 s loop: the magnetic collector idling - a tired little diesel putter,
    the electric hum of the magnet coil and the chain swinging now and then."""
    seconds = 2.0
    t = t_axis(seconds)
    out = np.zeros(int(seconds * SR))
    # Diesel: 9 puffs per second, a seamless whole number in the loop.
    for index in range(18):
        puff = lowpass(noise(0.07), 300) * env_exp(0.07, 0.03)
        mix_into(out, puff, index / 9.0, 0.55 + 0.15 * (index % 3 == 0))
    hum = np.sin(2 * np.pi * 100 * t) * 0.18 + np.sin(2 * np.pi * 200 * t) * 0.07 + np.sin(2 * np.pi * 300 * t) * 0.03
    out += hum * (0.85 + 0.15 * np.sin(2 * np.pi * 0.5 * t))
    for start in (0.35, 1.4):
        mix_into(out, metal_clank(1900, 0.12) * 0.5, start, 0.25)
    return finish(out, peak_db=-9, fade_out=0.0, fade_in=0.0)


def sfx_pry(variant):
    """Crowbar: wood groaning, a nail squealing out, a crack at the end."""
    local = np.random.default_rng(700 + variant)
    seconds = 0.9
    t = t_axis(seconds)
    groan = signal.sawtooth(2 * np.pi * np.cumsum(90 + 40 * t + local.uniform(-5, 5)) / SR)
    out = bandpass(groan, 120, 900) * 0.3 * np.minimum(1.0, t / 0.2)
    squeal_t = t_axis(0.35)
    squeal = np.sin(2 * np.pi * np.cumsum(1400 + 900 * squeal_t) / SR) * np.sin(np.pi * squeal_t / 0.35)
    mix_into(out, squeal, 0.3, 0.22)
    crack = bandpass(noise(0.08), 400, 4000) * env_exp(0.08, 0.02)
    mix_into(out, crack, 0.78, 0.9)
    return finish(reverb(out, 0.5, 0.15), peak_db=-6)


SFX = {
    "step": (sfx_footstep, 4), "clink": (sfx_clink, 3), "tin": (sfx_tin, 2), "wire": (sfx_wire, 2),
    "wood": (sfx_wood, 2), "brass": (sfx_brass, 1), "box": (sfx_box, 2), "basket": (sfx_basket, 2),
    "thud": (sfx_thud, 2), "nope": (sfx_nope, 1), "bell": (sfx_bell, 1), "kaching": (sfx_kaching, 1),
    "coins": (sfx_coins, 2), "page": (sfx_page, 2), "paper": (sfx_paper, 1), "phone": (sfx_phone, 1),
    "delivery": (sfx_delivery, 1), "jingle": (sfx_jingle, 1), "switch": (sfx_switch, 1), "pop": (sfx_pop, 3),
    "click": (sfx_click, 1), "rummage": (sfx_rummage, 1), "hoist": (sfx_hoist, 1), "screw": (sfx_screw, 1),
    "creak": (sfx_creak, 1), "scrappy_chirp": (sfx_scrappy_chirp, 4), "scrappy_wake": (sfx_scrappy_wake, 1),
    "spark": (sfx_spark, 2), "head_beep": (sfx_head_beep, 2),
    "van_horn": (sfx_van_horn, 1), "magnet_hum": (sfx_magnet_hum, 1), "pry": (sfx_pry, 2),
}
LOOPS = {"rummage", "hoist", "screw", "magnet_hum"}


def write_library(entries):
    """Godot resource mapping sound names to their variant streams."""
    lines = []
    ext = []
    sounds = []
    index = 2
    for name, paths in sorted(entries.items()):
        ids = []
        for path in paths:
            ext.append(f'[ext_resource type="AudioStream" path="{path}" id="{index}"]')
            ids.append(f'ExtResource("{index}")')
            index += 1
        sounds.append(f'"{name}": [{", ".join(ids)}]')
    lines.append(f'[gd_resource type="Resource" script_class="SoundLibrary" format=3]\n')
    lines.append('[ext_resource type="Script" path="res://scripts/audio/SoundLibrary.gd" id="1"]')
    lines.extend(ext)
    lines.append("\n[resource]")
    lines.append('script = ExtResource("1")')
    lines.append("sounds = {\n" + ",\n".join(sounds) + "\n}")
    lines.append(f'loops = PackedStringArray({", ".join(chr(34) + name + chr(34) for name in sorted(LOOPS))})')
    path = os.path.join(ROOT, "data", "audio", "sound_library.tres")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as handle:
        handle.write("\n".join(lines) + "\n")


def main():
    only = sys.argv[1] if len(sys.argv) > 1 else ""
    entries = {}
    for name, (builder, variants) in SFX.items():
        entries[name] = []
        for variant in range(variants):
            relative = f"assets/audio/sfx/{name}_{variant}.wav"
            if not only or only == name:
                write(os.path.join(ROOT, relative), builder(variant))
            entries[name].append("res://" + relative)
    write_library(entries)
    if not only or only == "music":
        write(os.path.join(ROOT, "assets/audio/music/old_yard_shuffle.wav"), old_yard_shuffle())
        write(os.path.join(ROOT, "assets/audio/music/every_scrap_has_a_story.wav"), every_scrap_has_a_story())
        write(os.path.join(ROOT, "assets/audio/ambience/yard_ambience.wav"), yard_ambience())
    print("SYNTH_DONE")


if __name__ == "__main__":
    main()
