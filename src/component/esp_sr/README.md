# esp_sr

Zig binding for the Espressif [ESP-SR](https://github.com/espressif/esp-sr) speech recognition framework.

## ESP-IDF component

Maps to [`esp-sr`](https://docs.espressif.com/projects/esp-sr/en/latest/esp32s3/index.html) (component registry: `espressif/esp-sr`).

## Module boundary

Provides typed Zig wrappers for the core ESP-SR audio processing and speech recognition sub-modules:

| Sub-module | File | Description |
|------------|------|-------------|
| **AFE** | `afe.zig` | Audio Front-end pipeline (orchestrates AEC, NS, VAD, AGC, WakeNet) |
| **AEC** | `aec.zig` | Standalone Acoustic Echo Cancellation |
| **NS** | `ns.zig` | Standalone Noise Suppression |
| **AGC** | `agc.zig` | Standalone Automatic Gain Control |
| **VAD** | `vad.zig` | Standalone Voice Activity Detection (WebRTC-based) |
| **MASE** | `mase.zig` | Microphone Array Speech Enhancement (beamforming for 2-mic / 3-mic arrays) |
| **MultiNet** | `multinet.zig` | Offline speech command recognition |

### AFE (Audio Front-end)

The AFE is the primary high-level pipeline. It combines AEC, NS, VAD, AGC, and WakeNet into a single feed/fetch interface. Typical usage:

1. Create AFE with desired sub-module enables
2. Feed interleaved PCM audio (mic + reference channels)
3. Fetch processed mono output with wake-word and VAD state

### Standalone algorithms

AEC, NS, AGC, and VAD can also be used independently outside the AFE pipeline for custom audio processing chains.

### MultiNet

Offline speech command recognition. After wake-word detection (via AFE), feed audio chunks to MultiNet for command matching against a registered phrase list.

### MASE (Microphone Array Speech Enhancement)

Beamforming for dual-mic or triple-mic arrays. Fixed at 16 kHz / 16 ms frame size. Supports configurable filter strength (0-3) and two operating modes (normal / wake-up enhanced). For a dual-mic system, feed interleaved 2-channel PCM and get enhanced single-channel output.

## Not yet covered

- **WakeNet** standalone interface (typically used via AFE)
- **DOA** (Direction of Arrival)
- **NSNet** (deep-learning noise suppression)
- **VADNet** (neural network VAD)
- **TTS** (text-to-speech)

## Dependencies

- ESP-IDF: `esp-sr`, `esp_partition_table`
- Model partition: ESP-SR models must be flashed to a `model` partition
- Chip: ESP32-S3 (primary target; some algorithms available on ESP32)
