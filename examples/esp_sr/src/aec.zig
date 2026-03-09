const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const heap = esp_component.heap;
const esp_sr = esp_component.esp_sr;
const audio = @import("audio.zig");

const printf = rom.esp_rom_printf;

extern fn esp_timer_get_time() i64;

fn usToMs(us: i64) u32 {
    return @intCast(@divTrunc(us, 1000));
}

fn runAec(aec: *esp_sr.Aec, input: []i16, ref: []i16, output: []i16, chunk: u32, total: u32) u32 {
    var frames: u32 = 0;
    var pos: u32 = 0;
    while (pos + chunk <= total) : (pos += chunk) {
        aec.process(
            input[pos .. pos + chunk],
            ref[pos .. pos + chunk],
            output[pos .. pos + chunk],
        ) catch break;
        frames += 1;
    }
    return frames;
}

const MemSnapshot = struct {
    total_free: u32,
    internal_free: u32,
    psram_free: usize,
    psram_total: usize,
    internal_caps_free: usize,
    internal_caps_total: usize,
};

fn takeMemSnapshot() MemSnapshot {
    const spiram_caps = heap.Caps.defaultPsram().raw;
    const internal_caps = heap.Caps.defaultInternal().raw;
    return .{
        .total_free = heap.freeHeapSize(),
        .internal_free = heap.freeInternalHeapSize(),
        .psram_free = heap.capsGetFreeSize(spiram_caps),
        .psram_total = heap.capsGetTotalSize(spiram_caps),
        .internal_caps_free = heap.capsGetFreeSize(internal_caps),
        .internal_caps_total = heap.capsGetTotalSize(internal_caps),
    };
}

fn printMemSnapshot(label: [*:0]const u8, snap: MemSnapshot) void {
    _ = printf("\n=== Memory: %s ===\n", label);
    _ = printf("  Total free:     %u bytes\n", snap.total_free);
    _ = printf("  Internal free:  %u bytes\n", snap.internal_free);
    _ = printf("  PSRAM:          %u / %u bytes free\n", @as(u32, @intCast(snap.psram_free)), @as(u32, @intCast(snap.psram_total)));
    _ = printf("  Internal(caps): %u / %u bytes free\n", @as(u32, @intCast(snap.internal_caps_free)), @as(u32, @intCast(snap.internal_caps_total)));
}

fn printMemDelta(label: [*:0]const u8, before: MemSnapshot, after: MemSnapshot) void {
    _ = printf("\n--- Memory delta: %s ---\n", label);
    const d_internal = @as(i32, @intCast(before.internal_caps_free)) - @as(i32, @intCast(after.internal_caps_free));
    const d_psram = @as(i32, @intCast(before.psram_free)) - @as(i32, @intCast(after.psram_free));
    _ = printf("  DRAM used:  %d bytes\n", d_internal);
    _ = printf("  PSRAM used: %d bytes\n", d_psram);
}

const AEC_FRAME_LEN: i32 = 512;
const NS_FRAME_MS = 10;
const NS_FRAME_SAMPLES: u32 = audio.SAMPLE_RATE * NS_FRAME_MS / 1000;
const AGC_FRAME_SAMPLES: u32 = NS_FRAME_SAMPLES;

pub fn run() void {
    _ = printf("\n\n========================================\n");
    _ = printf("  ESP-SR AEC/NS/AGC Benchmark\n");
    _ = printf("========================================\n\n");

    const mem_boot = takeMemSnapshot();
    printMemSnapshot("boot", mem_boot);

    // ── Allocate audio buffers in PSRAM ──
    _ = printf("\n[1] Allocating audio buffers in PSRAM...\n");

    const psram_alloc = heap.alloc.psram;

    const far_end = psram_alloc.alloc(i16, audio.TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc far_end\n");
        return;
    };
    const near_end = psram_alloc.alloc(i16, audio.TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc near_end\n");
        return;
    };
    const aec_out = psram_alloc.alloc(i16, audio.TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc aec_out\n");
        return;
    };
    const ns_out = psram_alloc.alloc(i16, audio.TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc ns_out\n");
        return;
    };
    const agc_out = psram_alloc.alloc(i16, audio.TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc agc_out\n");
        return;
    };

    const mem_after_alloc = takeMemSnapshot();
    printMemDelta("buffer allocation", mem_boot, mem_after_alloc);

    // ── Load audio: partition first, fallback to @embedFile ──
    _ = printf("\n[2] Loading audio data...\n");

    audio.loadAudio("far_end", far_end, audio.far_end_pcm);
    audio.loadAudio("near_end", near_end, audio.near_end_pcm);

    const rms_far = audio.computeRms(far_end);
    const rms_near = audio.computeRms(near_end);
    _ = printf("  far_end  RMS: %u\n", rms_far);
    _ = printf("  near_end RMS: %u\n", rms_near);
    _ = printf("  far_end  first 4: %d %d %d %d\n", far_end[0], far_end[1], far_end[2], far_end[3]);
    _ = printf("  near_end first 4: %d %d %d %d\n", near_end[0], near_end[1], near_end[2], near_end[3]);

    // ── Initialize algorithms ──
    _ = printf("\n[3] Initializing AEC...\n");
    const mem_before_aec = takeMemSnapshot();

    var aec_inst = esp_sr.Aec.init(.{
        .sample_rate = @intCast(audio.SAMPLE_RATE),
        .filter_length = 4,
        .channel_num = 1,
        .mode = .voip_high_perf,
    }) catch {
        _ = printf("FATAL: AEC init failed\n");
        return;
    };

    const mem_after_aec = takeMemSnapshot();
    printMemDelta("AEC init", mem_before_aec, mem_after_aec);

    const aec_chunk = aec_inst.getChunksize() catch {
        _ = printf("FATAL: AEC getChunksize failed\n");
        return;
    };
    _ = printf("  AEC chunk size: %d samples\n", aec_chunk);

    _ = printf("\n[4] Initializing NS...\n");
    const mem_before_ns = takeMemSnapshot();

    var ns = esp_sr.Ns.init(.{
        .frame_length = .ms10,
        .mode = .medium,
        .sample_rate = @intCast(audio.SAMPLE_RATE),
    }) catch {
        _ = printf("FATAL: NS init failed\n");
        return;
    };

    const mem_after_ns = takeMemSnapshot();
    printMemDelta("NS init", mem_before_ns, mem_after_ns);

    _ = printf("\n[5] Initializing AGC...\n");
    const mem_before_agc = takeMemSnapshot();

    var agc = esp_sr.Agc.init(.{
        .mode = .sr,
        .sample_rate = @intCast(audio.SAMPLE_RATE),
        .gain_db = 15,
        .limiter_enable = true,
        .target_level_dbfs = -3,
    }) catch {
        _ = printf("FATAL: AGC init failed\n");
        return;
    };

    const mem_after_agc = takeMemSnapshot();
    printMemDelta("AGC init", mem_before_agc, mem_after_agc);

    const mem_all_init = takeMemSnapshot();
    printMemSnapshot("after all init", mem_all_init);
    printMemDelta("total algorithm init", mem_before_aec, mem_all_init);

    const aec_chunk_u: u32 = @intCast(aec_chunk);

    // ── Test A: aec(far_end, far_end) — should cancel almost completely ──
    _ = printf("\n========================================\n");
    _ = printf("  Test A: aec(far_end, far_end)\n");
    _ = printf("  Input = ref => expect near-zero output\n");
    _ = printf("========================================\n");

    const t0_a = esp_timer_get_time();
    const frames_a = runAec(&aec_inst, far_end, far_end, aec_out, aec_chunk_u, audio.TOTAL_SAMPLES);
    const t1_a = esp_timer_get_time();

    const rms_a = audio.computeRms(aec_out);
    const peak_a = audio.computePeakAbs(aec_out);
    _ = printf("  Frames: %u in %u ms\n", frames_a, usToMs(t1_a - t0_a));
    _ = printf("  Input  RMS:  %u  peak: %u\n", rms_far, audio.computePeakAbs(far_end));
    _ = printf("  Output RMS:  %u  peak: %u\n", rms_a, peak_a);
    if (rms_far > 0) {
        _ = printf("  Suppression: %u%%\n", @as(u32, 100) -| (rms_a * 100 / rms_far));
    }

    // Re-init AEC for clean state
    aec_inst.deinit();
    aec_inst = esp_sr.Aec.init(.{
        .sample_rate = @intCast(audio.SAMPLE_RATE),
        .filter_length = 4,
        .channel_num = 1,
        .mode = .voip_high_perf,
    }) catch {
        _ = printf("FATAL: AEC re-init failed\n");
        return;
    };

    // ── Test B: aec(near_end, far_end) — preserve 1kHz sine ──
    _ = printf("\n========================================\n");
    _ = printf("  Test B: aec(near_end_sine, far_end_melody)\n");
    _ = printf("  Near=1kHz sine, Ref=melody => preserve sine\n");
    _ = printf("========================================\n");

    const t0_b = esp_timer_get_time();
    const frames_b = runAec(&aec_inst, near_end, far_end, aec_out, aec_chunk_u, audio.TOTAL_SAMPLES);
    const t1_b = esp_timer_get_time();

    const rms_b = audio.computeRms(aec_out);
    const peak_b = audio.computePeakAbs(aec_out);
    _ = printf("  Frames: %u in %u ms\n", frames_b, usToMs(t1_b - t0_b));
    _ = printf("  near_end input  RMS: %u  peak: %u\n", rms_near, audio.computePeakAbs(near_end));
    _ = printf("  AEC output      RMS: %u  peak: %u\n", rms_b, peak_b);

    // Sine sign consistency check (1-2s window, after AEC convergence)
    const check_start = audio.SAMPLE_RATE;
    const check_end = audio.SAMPLE_RATE * 2;
    var sign_match: u32 = 0;
    var sign_total: u32 = 0;
    {
        var i: u32 = check_start;
        while (i < check_end) : (i += 1) {
            if (near_end[i] != 0 and aec_out[i] != 0) {
                sign_total += 1;
                const in_pos = near_end[i] > 0;
                const out_pos = aec_out[i] > 0;
                if (in_pos == out_pos) sign_match += 1;
            }
        }
    }
    if (sign_total > 0) {
        _ = printf("  Sine sign consistency (1-2s): %u/%u (%u%%)\n", sign_match, sign_total, sign_match * 100 / sign_total);
    }

    // ── NS + AGC on Test B output ──
    _ = printf("\n[NS+AGC on Test B output]\n");

    var ns_frames: u32 = 0;
    const t0_ns = esp_timer_get_time();
    {
        var pos: u32 = 0;
        while (pos + NS_FRAME_SAMPLES <= audio.TOTAL_SAMPLES) : (pos += NS_FRAME_SAMPLES) {
            ns.process(
                aec_out[pos .. pos + NS_FRAME_SAMPLES],
                ns_out[pos .. pos + NS_FRAME_SAMPLES],
            ) catch break;
            ns_frames += 1;
        }
    }
    const t1_ns = esp_timer_get_time();

    var agc_frames: u32 = 0;
    const t0_agc = esp_timer_get_time();
    {
        var pos: u32 = 0;
        while (pos + AGC_FRAME_SAMPLES <= audio.TOTAL_SAMPLES) : (pos += AGC_FRAME_SAMPLES) {
            agc.process(
                ns_out[pos .. pos + AGC_FRAME_SAMPLES],
                agc_out[pos .. pos + AGC_FRAME_SAMPLES],
                @intCast(AGC_FRAME_SAMPLES),
            ) catch break;
            agc_frames += 1;
        }
    }
    const t1_agc = esp_timer_get_time();

    const rms_ns_out = audio.computeRms(ns_out);
    const rms_agc_out = audio.computeRms(agc_out);
    _ = printf("  NS:  %u frames in %u ms, RMS: %u\n", ns_frames, usToMs(t1_ns - t0_ns), rms_ns_out);
    _ = printf("  AGC: %u frames in %u ms, RMS: %u\n", agc_frames, usToMs(t1_agc - t0_agc), rms_agc_out);

    // ── Summary ──
    _ = printf("\n========================================\n");
    _ = printf("  Summary\n");
    _ = printf("========================================\n");
    _ = printf("  far_end (melody)     RMS: %u\n", rms_far);
    _ = printf("  near_end (1kHz sine) RMS: %u\n", rms_near);
    _ = printf("  Test A: aec(far,far) RMS: %u  (expect ~0)\n", rms_a);
    _ = printf("  Test B: aec(near,far)RMS: %u  (expect ~near)\n", rms_b);
    _ = printf("  Test B after NS      RMS: %u\n", rms_ns_out);
    _ = printf("  Test B after AGC     RMS: %u\n", rms_agc_out);

    const mem_final = takeMemSnapshot();
    printMemSnapshot("final", mem_final);
    printMemDelta("total from boot", mem_boot, mem_final);

    // ── Cleanup ──
    agc.deinit();
    ns.deinit();
    aec_inst.deinit();

    _ = printf("\n========================================\n");
    _ = printf("  ESP-SR benchmark complete.\n");
    _ = printf("========================================\n");
}
