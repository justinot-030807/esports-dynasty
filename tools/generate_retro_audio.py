import os
import math
import struct
import wave

SAMPLE_RATE = 22050

def make_wav(filename, duration, synth_fn):
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    num_samples = int(SAMPLE_RATE * duration)
    with wave.open(filename, 'w') as wav:
        wav.setnchannels(1) # mono
        wav.setsampwidth(2) # 16-bit
        wav.setframerate(SAMPLE_RATE)
        
        frames = bytearray()
        for i in range(num_samples):
            t = i / SAMPLE_RATE
            val = synth_fn(t, duration)
            val = max(-1.0, min(1.0, val))
            sample = int(val * 32767.0)
            frames.extend(struct.pack('<h', sample))
            
        wav.writeframes(frames)
    print(f"Generated: {filename} ({duration}s)")

# SFX Synths
def sfx_tap(t, d):
    # Short snappy pop
    freq = 600 - (t / d) * 400
    decay = math.exp(-t * 80)
    return 0.5 * math.sin(2 * math.pi * freq * t) * decay

def sfx_confirm(t, d):
    # Rising two-tone ding
    freq = 523.25 if t < 0.08 else 659.25 # C5 to E5
    decay = math.exp(-(t % 0.08) * 20)
    return 0.4 * (1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0) * decay

def sfx_cancel(t, d):
    # Falling tone
    freq = 440 - (t / d) * 200
    decay = math.exp(-t * 20)
    return 0.4 * (1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0) * decay

def sfx_coin(t, d):
    # Classic 8-bit coin B5 to E6
    freq = 987.77 if t < 0.07 else 1318.51
    decay = math.exp(-(t % 0.07) * 15)
    return 0.4 * math.sin(2 * math.pi * freq * t) * decay

def sfx_promotion(t, d):
    # Arpeggio C-E-G-C
    notes = [523.25, 659.25, 783.99, 1046.50]
    idx = min(int(t / 0.08), len(notes) - 1)
    decay = math.exp(-t * 5)
    return 0.4 * (1.0 if math.sin(2 * math.pi * notes[idx] * t) > 0 else -1.0) * decay

def sfx_win(t, d):
    # Triumphant fanfare
    notes = [523.25, 523.25, 523.25, 659.25, 783.99, 1046.50]
    idx = min(int(t / 0.1), len(notes) - 1)
    decay = math.exp(-t * 3)
    return 0.4 * (1.0 if math.sin(2 * math.pi * notes[idx] * t) > 0 else -1.0) * decay

def sfx_lose(t, d):
    # Sad wah wah
    freq = 250 - (t / d) * 120
    decay = math.exp(-t * 4)
    return 0.4 * (1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0) * decay

def sfx_popup(t, d):
    # Quick bubbly upward chirp
    freq = 400 + (t / d) * 600
    decay = math.exp(-t * 30)
    return 0.35 * math.sin(2 * math.pi * freq * t) * decay

def sfx_hit(t, d):
    # Noise burst impact
    noise = (hash(int(t * 100000)) % 1000) / 500.0 - 1.0
    freq = 150 - (t / d) * 100
    decay = math.exp(-t * 40)
    return (0.4 * math.sin(2 * math.pi * freq * t) + 0.3 * noise) * decay

def sfx_week_tick(t, d):
    # Gentle calendar tick
    freq = 880
    decay = math.exp(-t * 70)
    return 0.3 * math.sin(2 * math.pi * freq * t) * decay

def make_bgm(t, d, base_notes):
    # Looping retro chiptune melody
    step_time = 0.25
    step = int(t / step_time) % len(base_notes)
    freq = base_notes[step]
    decay = (1.0 - (t % step_time) / step_time) * 0.8 + 0.2
    # Square wave + bassline
    bass_freq = freq / 2.0
    lead = 0.25 * (1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0) * decay
    bass = 0.15 * (1.0 if math.sin(2 * math.pi * bass_freq * t) > 0 else -1.0)
    return lead + bass

def bgm_title(t, d):
    notes = [261.63, 329.63, 392.00, 523.25, 392.00, 329.63, 293.66, 349.23, 440.00, 587.33, 440.00, 349.23]
    return make_bgm(t, d, notes)

def bgm_house(t, d):
    notes = [329.63, 392.00, 493.88, 392.00, 261.63, 329.63, 392.00, 329.63]
    return make_bgm(t, d, notes)

def bgm_match(t, d):
    notes = [440.00, 440.00, 523.25, 587.33, 440.00, 392.00, 440.00, 659.25]
    return make_bgm(t, d, notes)

def bgm_finals(t, d):
    notes = [523.25, 587.33, 659.25, 783.99, 659.25, 783.99, 880.00, 1046.50]
    return make_bgm(t, d, notes)

if __name__ == '__main__':
    out_dir = 'assets/audio'
    make_wav(f'{out_dir}/sfx_tap.wav', 0.05, sfx_tap)
    make_wav(f'{out_dir}/sfx_confirm.wav', 0.16, sfx_confirm)
    make_wav(f'{out_dir}/sfx_cancel.wav', 0.15, sfx_cancel)
    make_wav(f'{out_dir}/sfx_coin.wav', 0.25, sfx_coin)
    make_wav(f'{out_dir}/sfx_promotion.wav', 0.35, sfx_promotion)
    make_wav(f'{out_dir}/sfx_win.wav', 0.60, sfx_win)
    make_wav(f'{out_dir}/sfx_lose.wav', 0.50, sfx_lose)
    make_wav(f'{out_dir}/sfx_popup.wav', 0.10, sfx_popup)
    make_wav(f'{out_dir}/sfx_hit.wav', 0.12, sfx_hit)
    make_wav(f'{out_dir}/sfx_week_tick.wav', 0.08, sfx_week_tick)
    
    # BGM tracks (short seamless looping chunks)
    make_wav(f'{out_dir}/bgm_title.wav', 3.0, bgm_title)
    make_wav(f'{out_dir}/bgm_house.wav', 2.0, bgm_house)
    make_wav(f'{out_dir}/bgm_match.wav', 2.0, bgm_match)
    make_wav(f'{out_dir}/bgm_finals.wav', 2.0, bgm_finals)
