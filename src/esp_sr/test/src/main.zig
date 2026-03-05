const esp_sr = @import("esp_sr");

comptime {
    _ = esp_sr.Afe;
    _ = esp_sr.Aec;
    _ = esp_sr.Ns;
    _ = esp_sr.Agc;
    _ = esp_sr.Vad;
    _ = esp_sr.Mase;
    _ = esp_sr.MultiNet;
}

export fn zig_esp_main() callconv(.c) void {}
