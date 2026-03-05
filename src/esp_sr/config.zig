const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("utils").config_overrides;

pub const module_name = "esp_sr";

pub const Config = struct {
    // ── Model data path ──

    /// Kconfig key: `CONFIG_MODEL_IN_FLASH`.
    /// Read model data from flash partition.
    /// Default: `true`.
    model_in_flash: bool = true,
    /// Kconfig key: `CONFIG_MODEL_IN_SDCARD`.
    /// Read model data from SD card.
    /// Default: `false`.
    model_in_sdcard: bool = false,

    // ── AFE interface ──

    /// Kconfig key: `CONFIG_AFE_INTERFACE_V1`.
    /// Use AFE interface version v1.
    /// Default: `true`.
    afe_interface_v1: bool = true,

    // ── Noise suppression model ──

    /// Kconfig key: `CONFIG_SR_NSN_WEBRTC`.
    /// Use WebRTC noise suppression.
    /// Default: `true`.
    sr_nsn_webrtc: bool = true,
    /// Kconfig key: `CONFIG_SR_NSN_NSNET2`.
    /// Use deep noise suppression v2 (nsnet2). Requires ESP32-S3 or ESP32-P4.
    /// Default: `false`.
    sr_nsn_nsnet2: bool = false,

    // ── VAD model ──

    /// Kconfig key: `CONFIG_SR_VADN_WEBRTC`.
    /// Use WebRTC voice activity detection.
    /// Default: `true`.
    sr_vadn_webrtc: bool = true,
    /// Kconfig key: `CONFIG_SR_VADN_VADNET1_MEDIUM`.
    /// Use VADNet1 medium model. Requires ESP32-S3 or ESP32-P4.
    /// Default: `false`.
    sr_vadn_vadnet1_medium: bool = false,

    // ── WakeNet9s models (lightweight, no PSRAM required) ──

    /// Kconfig key: `CONFIG_SR_WN_WN9S_HILEXIN`.
    /// Load wake word: Hi,乐鑫 (wn9s_hilexin).
    /// Default: `false`.
    sr_wn_wn9s_hilexin: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9S_HIESP`.
    /// Load wake word: Hi,ESP (wn9s_hiesp).
    /// Default: `false`.
    sr_wn_wn9s_hiesp: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9S_NIHAOXIAOZHI`.
    /// Load wake word: 你好小智 (wn9s_nihaoxiaozhi).
    /// Default: `false`.
    sr_wn_wn9s_nihaoxiaozhi: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9S_HIJASON`.
    /// Load wake word: Hi,Jason (wn9s_hijason).
    /// Default: `false`.
    sr_wn_wn9s_hijason: bool = false,

    // ── WakeNet9 models (full, requires ESP32-S3/P4/ESP32) ──

    /// Kconfig key: `CONFIG_SR_WN_WN9_HILEXIN`.
    /// Load wake word: Hi,乐鑫 (wn9_hilexin).
    /// Default: `false`.
    sr_wn_wn9_hilexin: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_HIESP`.
    /// Load wake word: Hi,ESP (wn9_hiesp).
    /// Default: `false`.
    sr_wn_wn9_hiesp: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_NIHAOXIAOZHI_TTS`.
    /// Load wake word: 你好小智 (wn9_nihaoxiaozhi_tts).
    /// Default: `false`.
    sr_wn_wn9_nihaoxiaozhi_tts: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_ALEXA`.
    /// Load wake word: Alexa (wn9_alexa).
    /// Default: `false`.
    sr_wn_wn9_alexa: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_HIJASON_TTS2`.
    /// Load wake word: Hi,Jason (wn9_hijason_tts2).
    /// Default: `false`.
    sr_wn_wn9_hijason_tts2: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_NIHAOMIAOBAN_TTS2`.
    /// Load wake word: 你好喵伴 (wn9_nihaomiaoban_tts2).
    /// Default: `false`.
    sr_wn_wn9_nihaomiaoban_tts2: bool = false,
    /// Kconfig key: `CONFIG_SR_WN_WN9_XIAOAITONGXUE`.
    /// Load wake word: 小爱同学 (wn9_xiaoaitongxue).
    /// Default: `false`.
    sr_wn_wn9_xiaoaitongxue: bool = false,

    // ── Chinese MultiNet model ──

    /// Kconfig key: `CONFIG_SR_MN_CN_NONE`.
    /// No Chinese speech command model.
    /// Default: `true`.
    sr_mn_cn_none: bool = true,
    /// Kconfig key: `CONFIG_SR_MN_CN_MULTINET5_RECOGNITION_QUANT8`.
    /// Chinese recognition (mn5q8_cn). Requires ESP32-S3.
    /// Default: `false`.
    sr_mn_cn_multinet5_recognition_quant8: bool = false,
    /// Kconfig key: `CONFIG_SR_MN_CN_MULTINET6_QUANT`.
    /// General Chinese recognition (mn6_cn). Requires ESP32-S3.
    /// Default: `false`.
    sr_mn_cn_multinet6_quant: bool = false,
    /// Kconfig key: `CONFIG_SR_MN_CN_MULTINET7_QUANT`.
    /// General Chinese recognition (mn7_cn). Requires ESP32-S3 or ESP32-P4.
    /// Default: `false`.
    sr_mn_cn_multinet7_quant: bool = false,

    // ── English MultiNet model ──

    /// Kconfig key: `CONFIG_SR_MN_EN_NONE`.
    /// No English speech command model.
    /// Default: `true`.
    sr_mn_en_none: bool = true,
    /// Kconfig key: `CONFIG_SR_MN_EN_MULTINET5_SINGLE_RECOGNITION_QUANT8`.
    /// English recognition (mn5q8_en). Requires ESP32-S3.
    /// Default: `false`.
    sr_mn_en_multinet5_single_recognition_quant8: bool = false,
    /// Kconfig key: `CONFIG_SR_MN_EN_MULTINET6_QUANT`.
    /// General English recognition (mn6_en). Requires ESP32-S3.
    /// Default: `false`.
    sr_mn_en_multinet6_quant: bool = false,
    /// Kconfig key: `CONFIG_SR_MN_EN_MULTINET7_QUANT`.
    /// General English recognition (mn7_en). Requires ESP32-S3 or ESP32-P4.
    /// Default: `false`.
    sr_mn_en_multinet7_quant: bool = false,
};

pub const default: Config = .{};

pub fn withDefaultConfig(overrides: anytype) Config {
    return config_overrides.withDefaultConfig(Config, overrides);
}

pub fn appendModuleDoc(
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
    cfg: Config,
) std.mem.Allocator.Error!void {
    const entries = try allocator.alloc(sdkconfig.Entry, 28);

    entries[0] = sdkconfig.Entry.flag("CONFIG_MODEL_IN_FLASH", cfg.model_in_flash);
    entries[1] = sdkconfig.Entry.flag("CONFIG_MODEL_IN_SDCARD", cfg.model_in_sdcard);
    entries[2] = sdkconfig.Entry.flag("CONFIG_AFE_INTERFACE_V1", cfg.afe_interface_v1);
    entries[3] = sdkconfig.Entry.flag("CONFIG_SR_NSN_WEBRTC", cfg.sr_nsn_webrtc);
    entries[4] = sdkconfig.Entry.flag("CONFIG_SR_NSN_NSNET2", cfg.sr_nsn_nsnet2);
    entries[5] = sdkconfig.Entry.flag("CONFIG_SR_VADN_WEBRTC", cfg.sr_vadn_webrtc);
    entries[6] = sdkconfig.Entry.flag("CONFIG_SR_VADN_VADNET1_MEDIUM", cfg.sr_vadn_vadnet1_medium);
    entries[7] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9S_HILEXIN", cfg.sr_wn_wn9s_hilexin);
    entries[8] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9S_HIESP", cfg.sr_wn_wn9s_hiesp);
    entries[9] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9S_NIHAOXIAOZHI", cfg.sr_wn_wn9s_nihaoxiaozhi);
    entries[10] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9S_HIJASON", cfg.sr_wn_wn9s_hijason);
    entries[11] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_HILEXIN", cfg.sr_wn_wn9_hilexin);
    entries[12] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_HIESP", cfg.sr_wn_wn9_hiesp);
    entries[13] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_NIHAOXIAOZHI_TTS", cfg.sr_wn_wn9_nihaoxiaozhi_tts);
    entries[14] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_ALEXA", cfg.sr_wn_wn9_alexa);
    entries[15] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_HIJASON_TTS2", cfg.sr_wn_wn9_hijason_tts2);
    entries[16] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_NIHAOMIAOBAN_TTS2", cfg.sr_wn_wn9_nihaomiaoban_tts2);
    entries[17] = sdkconfig.Entry.flag("CONFIG_SR_WN_WN9_XIAOAITONGXUE", cfg.sr_wn_wn9_xiaoaitongxue);
    entries[18] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_NONE", cfg.sr_mn_cn_none);
    entries[19] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_MULTINET5_RECOGNITION_QUANT8", cfg.sr_mn_cn_multinet5_recognition_quant8);
    entries[20] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_MULTINET6_QUANT", cfg.sr_mn_cn_multinet6_quant);
    entries[21] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_MULTINET7_QUANT", cfg.sr_mn_cn_multinet7_quant);
    entries[22] = sdkconfig.Entry.flag("CONFIG_SR_MN_EN_NONE", cfg.sr_mn_en_none);
    entries[23] = sdkconfig.Entry.flag("CONFIG_SR_MN_EN_MULTINET5_SINGLE_RECOGNITION_QUANT8", cfg.sr_mn_en_multinet5_single_recognition_quant8);
    entries[24] = sdkconfig.Entry.flag("CONFIG_SR_MN_EN_MULTINET6_QUANT", cfg.sr_mn_en_multinet6_quant);
    entries[25] = sdkconfig.Entry.flag("CONFIG_SR_MN_EN_MULTINET7_QUANT", cfg.sr_mn_en_multinet7_quant);

    _ = entries[26..28];
    entries[26] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_MULTINET6_AC_QUANT", false);
    entries[27] = sdkconfig.Entry.flag("CONFIG_SR_MN_CN_MULTINET7_AC_QUANT", false);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
