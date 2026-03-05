pub const config = @import("config.zig");

pub const afe = @import("afe.zig");
pub const aec = @import("aec.zig");
pub const ns = @import("ns.zig");
pub const agc = @import("agc.zig");
pub const vad = @import("vad.zig");
pub const mase = @import("mase.zig");
pub const multinet = @import("multinet.zig");

pub const Afe = afe.Afe;
pub const Aec = aec.Aec;
pub const Ns = ns.Ns;
pub const Agc = agc.Agc;
pub const Vad = vad.Vad;
pub const Mase = mase.Mase;
pub const MultiNet = multinet.MultiNet;

pub const module_name = "esp_sr";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "espressif__esp-sr", "partition_table" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};

pub const idf_external_components = [_]struct { name: []const u8, version: []const u8 }{
    .{ .name = "espressif/esp-sr", .version = "2.3.1" },
};
